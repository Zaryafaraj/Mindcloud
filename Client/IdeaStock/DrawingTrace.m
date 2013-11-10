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

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.path forKey:@"path"];
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeInteger:self.drawingType forKey:@"drawingType"];
    [aCoder encodeObject:self.drawingId forKey:@"drawingId"];
    [aCoder encodeFloat:self.lineWidth forKey:@"lineWidth"];
}

-(id) initWithCoder:(NSCoder *) aCoder
{
    self = [super init];
    if (self)
    {
        self.path = [aCoder decodeObjectForKey:@"path"];
        self.color = [aCoder decodeObjectForKey:@"color"];
        self.drawingType = [aCoder decodeIntegerForKey:@"drawingType"];
        self.drawingId = [aCoder decodeObjectForKey:@"drawingId"];
        self.lineWidth = [aCoder decodeFloatForKey:@"lineWidth"];
    }
    return self;
}

@end
