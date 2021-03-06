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

-(instancetype) initWithPath:(UIBezierPath *) path
                    andColor:(UIColor *) color
                andLineWidth:(CGFloat) lineWidth
                     andType:(DrawingTraceType) type;

-(instancetype) initWithId:(NSString *)drawingId
                      Path:(UIBezierPath *)path
                  andColor:(UIColor *)color
              andLineWidth:(CGFloat) lineWidth
                   andType:(DrawingTraceType)type;

@property UIBezierPath * path;

@property UIColor * color;

@property CGFloat lineWidth;

@property DrawingTraceType drawingType;

@property NSString * drawingId;

@end
