//
//  MultimediaHelper.h
//  Lists
//
//  Created by Ali Fathalian on 4/28/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultimediaHelper : NSObject

+ (CGImageRef)clipImageFromLayer:(CALayer *)layer
                            size:(CGSize)size
                         offsetX:(CGFloat)offsetX;
@end
