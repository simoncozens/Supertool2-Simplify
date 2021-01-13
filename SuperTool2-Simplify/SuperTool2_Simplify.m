//
//  SuperTool2_Simplify.m
//  SuperTool2-Simplify
//
//  Created by Simon Cozens on 13/01/2021.
//
//

#import "SuperTool2_Simplify.h"
#import <GlyphsCore/GSFont.h>
#import <GlyphsCore/GSFontMaster.h>
#import <GlyphsCore/GSGlyph.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSPath.h>
#import <GlyphsCore/GSCallbackHandler.h>
#import <GlyphsCore/GSProxyShapes.h>

@implementation SuperTool2_Simplify

- (id) init {
	self = [super init];
	[NSBundle loadNibNamed:@"SuperTool2_SimplifyDialog" owner:self];
    simplifySegSet = [[NSMutableArray alloc] init];
    simplifySpliceSet = [[NSMutableArray alloc] init];
    simplifyPathSet = [[NSMutableArray alloc] init];
    return self;
}

- (NSUInteger) interfaceVersion {
	// Distinguishes the API verison the plugin was built for. Return 1.
	return 1;
}

- (NSString*) title {
	// Return the name of the tool as it will appear in the menu.
	return @"SuperTool - Simplify";
}

- (NSString*) actionName {
	// The title of the button in the filter dialog.
	return @"Simplify";
}

- (NSString*) keyEquivalent {
	// The key together with Cmd+Shift will be the shortcut for the filter.
	// Return nil if you do not want to set a shortcut.
	// Users can set their own shortcuts in System Prefs.
	return nil;
}

- (NSError*) setup {
	if ([_fontMaster.userData objectForKey:@"simplify-precision"]) {
		_precision = [[_fontMaster.userData objectForKey:@"simplify-precision"] floatValue];
	}
	else {
		_precision = 6; // set default value.
	}
	[_precisionField setFloatValue:_precision];

    if ([_fontMaster.userData objectForKey:@"simplify-corners"]) {
        _corners = [[_fontMaster.userData objectForKey:@"simplify-corners"] floatValue];
    }
    else {
        _corners = 5; // set default value.
    }
    [_precisionField setFloatValue:_precision];
    [_cornersField setFloatValue:_corners];

    return nil;
}

- (void) processLayer:(GSLayer*)Layer withPrecision:(CGFloat)precision withCorners:(CGFloat)corners{
	// the method should contain all parameters as arguments
    NSMutableOrderedSet* sel = [Layer selection];
    [simplifySegSet removeAllObjects];
    [simplifySpliceSet removeAllObjects];
    [simplifyPathSet removeAllObjects];
    GSNode *n, *nn;
    NSMutableArray *mySelection = [sel mutableCopy];
    SCLog(@"Sorting selection %@", mySelection);
    [mySelection sortUsingComparator:^ NSComparisonResult(GSNode* a, GSNode*b) {
        GSPath *p = [a parentPath];
        if (p != [b parent]) {
            GSLayer *l = [[p parent] layer];
            return [l indexOfObjectInShapes:p] < [l indexOfObjectInShapes:[b parentPath]] ? NSOrderedAscending : NSOrderedDescending;
        }
        return ([p indexOfNode:a] < [p indexOfNode:b]) ? NSOrderedAscending : NSOrderedDescending;
    }];
    SCLog(@"Selection is now %@", mySelection);
    for (n in mySelection) {
        nn = [n nextOnCurve];
        if ([[nn parentPath] indexOfNode:nn] < [[n parentPath] indexOfNode:n]) {
            continue;
        }
                SCLog(@"Considering %@ (parent: %@, index %ld), next-on-curve: %@", n, [n parentPath], [[n parentPath] indexOfNode:n], nn);
        if ([mySelection containsObject:nn]) {
            [self addToSelectionSegmentStarting:n Ending:nn];
                        SCLog(@"Added %@ -> %@ (next), Selection set is %@", n, nn, simplifySegSet);
        }
    }
    NSMutableArray *a;
    for (a in simplifySegSet) {
        GSNode *b = [a firstObject];
        GSNode *e = [a lastObject];
        SCLog(@"Fixing seg set to splice set: %@, %@ (parents: %@, %@)", b, e, [b parent], [e parent]);
        NSUInteger bIndex = [[b parentPath] indexOfNode:b];
        NSUInteger eIndex = [[e parentPath] indexOfNode:e];
        NSRange range = NSMakeRange(bIndex, eIndex-bIndex);
        [simplifySpliceSet addObject:[NSValue valueWithRange:range]];
        // Here we must add the original parent
        SCLog(@"Added range %lu, %lu", (unsigned long)bIndex, (unsigned long)eIndex);
        [simplifyPathSet addObject:[b parent]];
    }
    
    //    SCLog(@"Splice set is %@", simplifySpliceSet);
    SCLog(@"Path set is %@", simplifyPathSet);

    CGFloat reducePercentage = [_precisionField maxValue] - precision + [_precisionField minValue];
    CGFloat cornerTolerance = [_cornersField maxValue] - _corners + [_cornersField minValue];
    int i = 0;
    //    SCLog(@"Seg set is %@", simplifySegSet);
    //    SCLog(@"copied paths is %@", copiedPaths);
    //    SCLog(@"original paths is %@", originalPaths);
    while (i <= [simplifySegSet count]-1) {
        NSMutableArray* s = simplifySegSet[i];
        GSPath* p = simplifyPathSet[i];
        NSRange startEnd = [simplifySpliceSet[i] rangeValue];
        SCLog(@"Must reduce %@ (%li, %f)", s, (unsigned long)[s count], reducePercentage);
        
        if ([[s firstObject] parent]) {
            SCLog(@"ALERT! Parent of %@ is %@", [s firstObject], [[s firstObject]parent]);
        } else {
            SCLog(@"Parent dead before simplifying!");
            return;
        }
        GSPath *newPath = [SCCurveFitter fitCurveToPoints:s withError:reducePercentage cornerTolerance: cornerTolerance maxSegments:240];
        
        NSUInteger newend = [self splice:newPath into:p at:startEnd];
        SCLog(@"New end is %lu",(unsigned long)newend );
        simplifySpliceSet[i] = [NSValue valueWithRange:NSMakeRange(startEnd.location, newend)];
        if (![[s firstObject] parent]) {
            SCLog(@"ALERT! Parent dead after simplifying!");
        }
        //        NSUInteger j = startEnd.location;
        //        while (j <= startEnd.location+newend) {
        //            [self harmonize:[p nodeAtIndex:j++]];
        //        }
        SCLog(@"Simplify splice set = %@", simplifySpliceSet);
        i++;
    }
}

- (void) processFont:(GSFont*)Font withArguments:(NSArray*)Arguments {
    // No. Not doing it.
}

- (IBAction) setPrecision:(id)sender {
	CGFloat p = [sender floatValue];
	if(fabs(p - _precision) > 0.01) {
		_precision = p;
		[self process:nil];
	}
}

- (IBAction) setCorners:(id)sender {
    CGFloat c = [sender floatValue];
    if(fabs(c - _corners) > 0.01) {
        _corners = c;
        [self process:nil];
    }
}


- (void) process:(id)sender {
    NSLog(@"Processing %@", _shadowLayers);
	int k;
	for (k = 0; k < [_shadowLayers count]; k++) {
		GSLayer * ShadowLayer = [_shadowLayers objectAtIndex:k];
		GSLayer * Layer = [_layers objectAtIndex:k];
		Layer.shapes = [[NSMutableArray alloc] initWithArray:ShadowLayer.shapes copyItems:YES];
		Layer.selection = [[NSMutableOrderedSet alloc] init];
        if ([ShadowLayer.selection count] > 0) {
			int i, j;
			for (i = 0; i < [ShadowLayer.shapes count]; i++) {
				GSShape * currShadowShape = [ShadowLayer.shapes objectAtIndex:i];
				GSShape * currLayerShape = [Layer.shapes objectAtIndex:i];
                if (currShadowShape.shapeType != GSShapeTypePath) continue;
                GSPath* currShadowPath = (GSPath*)currShadowShape;
                GSPath* currLayerPath = (GSPath*)currLayerShape;
				for (j = 0; j < [currShadowPath.nodes count]; j++) {
					GSNode * currShadowNode = [currShadowPath.nodes objectAtIndex:j];
					if ([ShadowLayer.selection containsObject:currShadowNode]) {
						[Layer addSelection:[currLayerPath.nodes objectAtIndex:j]];
					}
				}
			}
		}
        NSLog(@"Processing layer %@", Layer);
        [self processLayer:Layer withPrecision:_precision withCorners:_corners];
		[Layer clearSelection];
	}
	// Safe the value in the FontMaster. But could be saved in UserDefaults, too.
	[(NSMutableDictionary*)(_fontMaster.userData) setObject:[NSNumber numberWithDouble:_precision] forKey:@"simplify-precision"];
    [(NSMutableDictionary*)(_fontMaster.userData) setObject:[NSNumber numberWithDouble:_corners] forKey:@"simplify-corners"];
	[super process:nil];
}

- (NSUInteger)splice:(GSPath*)newPath into:(GSPath*)path at:(NSRange)splice {
    GSNode* n;
    SCLog(@"Splicing into path %@, at range %lu-%lu", path, (unsigned long)splice.location, (unsigned long)NSMaxRange(splice));
    long j = NSMaxRange(splice);
    while (j >= 0 && j >= splice.location) {
        [path removeObjectFromNodesAtIndex:j];
        j--;
    }
    for (n in [newPath nodes]) {
        GSNode *n2 = [n copy];
        [path insertObject:n2 inNodesAtIndex:++j];
    }
    splice.length =  [newPath countOfNodes] -1;
    j = splice.location;
    while (j - splice.location < splice.length ) {
        j++;
    }
    if ([[[path nodeAtIndex:j] nextNode] type] != OFFCURVE) {
        [path nodeAtIndex:j].type = LINE;
    }
    if ([[[path nodeAtIndex:splice.location] prevNode] type] != OFFCURVE) {
        [path nodeAtIndex:splice.location].type = LINE;
    }
    [path checkConnections];
    SCLog(@"spliced path: %@", [path nodes]);
    return [newPath countOfNodes] -1;
}

// Ensure selection array contains [s,e]
- (void) addToSelectionSegmentStarting:(GSNode*)s Ending:(GSNode*)e {
    NSMutableArray *a;
    for (a in simplifySegSet) {
        // Are s e already in the array? Go home
        if ([a containsObject:s] && [a containsObject:e]) { return; }
        // Is s the last member of any array? Add e after it.
        if ([a lastObject] == s) {
            [a addObject:e];
            return;
        }
        // Is e the first member of any array? Add s before it.
        if ([a firstObject] == e) {
            [a insertObject:s atIndex:0];
            return;
        }
    }
    // Create a new entry for [s,e]
    NSMutableArray *holder = [[NSMutableArray alloc]initWithObjects:(GSNode*)s,e, nil];
    [simplifySegSet addObject: holder];
}

@end
