//
//  DrawingTrace.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/18/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DrawingTraceType)
{
    DrawingTraceTypePaint,
    DrawingTraceTypeErase
};

@interface DrawingTrace : NSObject

-(instancetype) initWithPath:(CGPathRef) path
                    andColor:(UIColor *) color
                     andType:(DrawingTraceType) type;

-(instancetype) initWithId:(NSString *) drawingId
                      Path:(CGPathRef) path
                    andColor:(UIColor *) color
                     andType:(DrawingTraceType) type;

@property CGPathRef path;

@property UIColor * color;

@property DrawingTraceType drawingType;

@property NSString * drawingId;

@end
