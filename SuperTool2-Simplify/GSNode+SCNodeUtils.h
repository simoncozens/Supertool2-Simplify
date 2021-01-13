//
//  GSNode+SCNodeUtils.h
//  SuperTool
//
//  Created by Simon Cozens on 21/05/2016.
//  Copyright © 2016 Simon Cozens. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GlyphsCore/GlyphsCore.h>
#import <GlyphsCore/GSNode.h>
#import <GlyphsCore/GSPath.h>
#import <GlyphsCore/GSGeometrieHelper.h>

@interface GSNode (SCNodeUtils)

/*! Returns the next node in the owning path
 * \returns The next node, whether on or off curve
 */
- (GSNode*) nextNode;

/*! Returns the previous node in the owning path
 * \returns The previous node, whether on or off curve
 */
- (GSNode*) prevNode;


/*! Returns the next on-curve node in the owning path
 * \returns The next on-curve node
 */
- (GSNode*) nextOnCurve;

/*! Returns the previous on-curve node in the owning path
 * \returns The previous on-curve node
 */
- (GSNode*) prevOnCurve;

/*! Corrects a smooth connection, ensuring off-curves are aligned
*/
- (void) correct;
@end
