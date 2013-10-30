//
//  BrushColors.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/30/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "BrushColors.h"

@interface BrushColors ()

@property (nonatomic, strong) NSArray * colors;
@property (nonatomic, strong) NSSet * lightColors;

@end

@implementation BrushColors

-(id) init
{
    self = [super init];
    if (self)
    {
        [self setupColors];
    }
    return self;
}

-(void) setupColors
{
    UIColor * black = [UIColor blackColor];
    UIColor * silver = [UIColor colorWithHue:0.567 saturation:0.050 brightness:0.741 alpha:1.000];
    UIColor * white =[UIColor colorWithHue:0.000 saturation:0.000 brightness:0.971 alpha:1.000];
    //[UIColor whiteColor];
    UIColor * alizarin = [UIColor colorWithHue:0.008 saturation:0.743 brightness:0.929 alpha:1.000];
    UIColor * carrot = [UIColor colorWithHue:0.068 saturation:0.805 brightness:0.925 alpha:1.000] ;
    UIColor * sunFlower = [UIColor colorWithHue:0.134 saturation:0.900 brightness:0.945 alpha:1.000];
    UIColor * turquioise = [UIColor colorWithHue:0.460 saturation:0.701 brightness:0.761 alpha:1.000];
    UIColor * emerald = [UIColor colorWithHue:0.404 saturation:0.697 brightness:0.827 alpha:1.000];
    UIColor * peterRiver = [UIColor colorWithHue:0.569 saturation:0.726 brightness:0.859 alpha:1.000];
    UIColor * amethyst = [UIColor colorWithHue:0.785 saturation:0.511 brightness:0.714 alpha:1.000];
    
    self.colors = @[black,
                    silver,
                    white,
                    alizarin,
                    carrot,
                    sunFlower,
                    turquioise,
                    emerald,
                    peterRiver,
                    amethyst];
    
    self.lightColors = [NSSet setWithArray:@[white]];
}

-(NSSet *) getLightColors
{
    return self.lightColors;
}

#define NUMBER_OF_COLORS 10
-(int) numberOfColors
{
    return NUMBER_OF_COLORS;
}

-(UIColor *) colorForIndexPath:(NSIndexPath *) indexPath
{
    int index = indexPath.item;
    return self.colors[index];
}

@end
