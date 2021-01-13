//
//  SCCurveFitter.h
//  SuperTool
//
//  Created by Simon Cozens on 03/04/2017.
//  Copyright © 2017 Simon Cozens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GlyphsToolEventProtocol.h>
#import <GlyphsCore/GlyphsPathPlugin.h>
#import <GlyphsCore/GSToolSelect.h>
#import <GlyphsCore/GSLayer.h>
#import <GlyphsCore/GSPath.h>
#import <GlyphsCore/GSGeometrieHelper.h>
#import "GSPath+SCPathUtils.h"

@interface SCCurveFitter : NSObject

/*! Creates a smooth path between the given points
 * \param data An array of GSNodes
 * \param error A tolerance value for curve fitting
 * \param corner Tolerance value for corner detection
 * \param maxSegments The maximum number of segments
 * \returns A GSPath Bezier curve or NULL if no curve would fit
 */
+ (GSPath*)fitCurveToPoints:(NSArray*)data withError:(double)error cornerTolerance:(double)corner maxSegments:(double)maxSegments;


+ (GSPath*) generateBezierFromPoints:(NSArray*)data withParameters:(NSArray*)u leftTangent: (NSPoint)tHat1 rightTangent: (NSPoint)tHat2 error:(double) error;

+ (NSMutableArray*)estimateLengths:(NSArray*)data parameters:(NSArray*)u left:(NSPoint)est_tHat1 right:(NSPoint)est_tHat2;
//+ (void)estimateBi:(NSMutableArray*)bez ei:(NSUInteger)ei data:(NSArray*)data parameters:(NSArray*)u;
@end
