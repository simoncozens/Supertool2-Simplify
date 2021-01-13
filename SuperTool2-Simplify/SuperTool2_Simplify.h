//
//  SuperTool2_Simplify.h
//  SuperTool2-Simplify
//
//  Created by Simon Cozens on 13/01/2021.
//
//

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GSFilterPlugin.h>

@interface SuperTool2_Simplify : GSFilterPlugin {
	CGFloat _firstValue;
	NSTextField * __unsafe_unretained _firstValueField;
}
@property (nonatomic, assign) IBOutlet NSTextField* firstValueField;
@end
