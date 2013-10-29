//
//  DrawingTrace.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/18/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "DrawingTrace.h"
#import "AttributeHelper.h"

@implementation DrawingTrace

-(instancetype) initWithPath:(UIBezierPath *) path
                    andColor:(UIColor *) color
                andLineWidth:(CGFloat) lineWidth
                     andType:(DrawingTraceType) type
{
    
    NSString * drawingId = [AttributeHelper generateUUID];
    self = [self initWithId:drawingId
                       Path:path
                   andColor:color
               andLineWidth:lineWidth
                    andType:type];
    return self;
}


-(instancetype) initWithId:(NSString *)drawingId
                      Path:(UIBezierPath *)path
                  andColor:(UIColor *)color
              andLineWidth:(CGFloat) lineWidth
                   andType:(DrawingTraceType)type
{
    
    self = [super init];
    if (self)
    {
        self.path = path;
        self.color = color;
        self.drawingType = type;
        self.drawingId = drawingId;
        self.lineWidth = lineWidth;
    }
    return self;
}

@end
