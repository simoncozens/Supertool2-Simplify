//
//  GSPath+SCPathUtils.h
//  SuperTool
//
//  Created by Simon Cozens on 14/07/2016.
//  Copyright © 2016 Simon Cozens. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GlyphsCore.h>
#import <GlyphsCore/GSNode.h>
#import <GlyphsCore/GSPath.h>
#import <GlyphsCore/GSGeometrieHelper.h>

@interface GSPath (SCPathUtils)

#pragma mark Initializers and mutators

/*! Initializes a path as a simple cubic Bezier from four NSPoints
 * \param p0 The start point
 * \param p1 The first off-curve control point
 * \param p2 The second off-curve control point
 * \param p3 The end point
 */
+ (GSPath*)initWithp0:(NSPoint)p0 p1:(NSPoint)p1 p2:(NSPoint)p2 p3:(NSPoint)p3;

/*! Initializes a path as a simple cubic Bezier from an array NSPoints
 * \param pts An NSArray of (at least) four NSValue-wrapped NSPoints.
 */

+ (GSPath*)initWithPointArray:(NSArray*)pts;

/*! Creates an off-curve node at the given position and adds it to the path
 * \param pos A position
*/
-(void)addOffcurve:(NSPoint)pos;

/*! Creates an smooth connection node at the given position and adds it to the path
 * \param pos A position
*/
-(void)addSmooth:(NSPoint)pos;

/*! Adds the nodes from the given path to the current one
 * \param source A GSPath. Its nodes are added to the end of self
*/
- (void)append:(GSPath*)source;

#pragma mark Finding information

/*! Finds the distance between the point and the path
 * \param p A point
 * \returns The smallest distance between the point and the path
 */

- (CGFloat)distanceFromPoint:(NSPoint)p;

/*! Finds the distance between the point and the path, but really quickly
 * \param aPoint A point
 * \param maxDistance The furthest distance away from the path worth checking
 * \returns The smallest distance between the point and the path
 */
- (CGFloat)distanceFromPoint:(NSPoint)aPoint maxDistance:(CGFloat)maxDistance;


/*! Finds the location of the curve at the given time.
 * Assumes a simple four-element Bezier!
 * \param t a time value from 0 to 1

 * \returns A vector representing the curvature
 */

- (NSPoint)SCPointAtPathTime:(CGFloat)t;

/*! Finds the first derivative of the curve at the given time.
 * Assumes a simple four-element Bezier!
 * \param t a time value from 0 to 1
 * \returns A vector representing the tangent
 */

- (NSPoint)qPrimeAtTime:(CGFloat)t;

/*! Finds the second derivative of the curve at the given time.
 * Assumes a simple four-element Bezier!
 * \param t a time value from 0 to 1
 * \returns A vector representing the curvature
 */

- (NSPoint)qPrimePrimeAtTime:(CGFloat)t;
@end
