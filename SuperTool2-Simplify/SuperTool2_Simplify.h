//
//  SuperTool2_Simplify.h
//  SuperTool2-Simplify
//
//  Created by Simon Cozens on 13/01/2021.
//
//

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GSFilterPlugin.h>
#import "GSPath+SCPathUtils.h"
#import "GSNode+SCNodeUtils.h"
#import "SCCurveFitter.h"

@interface SuperTool2_Simplify : GSFilterPlugin {
	CGFloat _precision;
    CGFloat _corners;
	NSSlider * __unsafe_unretained _precisionField;
    NSSlider * __unsafe_unretained _cornersField;
    // Simplify data storage
    NSMutableArray* simplifySegSet;
    NSMutableArray* simplifySpliceSet;
    NSMutableArray* simplifyPathSet;
}
@property (nonatomic, assign) IBOutlet NSSlider* precisionField;
@property (nonatomic, assign) IBOutlet NSSlider* cornersField;

@end
