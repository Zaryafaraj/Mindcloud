//
//  BrushColors.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/30/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "BrushColors.h"
#import "ThemeFactory.h"

@interface BrushColors ()

@property (nonatomic, strong) NSArray * colors;
@property (nonatomic, strong) NSSet * lightColors;
@property (nonatomic) NSInteger defaultColorIndex;

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
    UIColor * asbestos = [self colorFromRed:127 Green:140 andBlue:141];
    UIColor * concrete = [self colorFromRed:149 Green:165 andBlue:166];
    UIColor * silver = [self colorFromRed:189 Green:195 andBlue:199];
    UIColor * clouds = [self colorFromRed:236 Green:240 andBlue:241];
    UIColor * alizarin = [self colorFromRed:231 Green:76 andBlue:60];
    UIColor * windRed = [self colorFromRed:230 Green:86 andBlue:122];
    UIColor * pomegranate =[self colorFromRed:192 Green:57 andBlue:43];
    UIColor * pumpkin = [self colorFromRed:211 Green:84 andBlue:0];
    UIColor * carrot = [self colorFromRed:230 Green:126 andBlue:34];
    UIColor * portlandYellow = [self colorFromRed:234 Green:193 andBlue:77];
    UIColor * sunflower = [self colorFromRed:241 Green:196 andBlue:15];
    UIColor * orange = [self colorFromRed:243 Green:156 andBlue:18];
    UIColor * greenSea = [self colorFromRed:22 Green:160 andBlue:133];
    UIColor * turquoise = [self colorFromRed:26 Green:188 andBlue:156];
    UIColor * grassGreen = [self colorFromRed:91 Green:217 andBlue:153];
    UIColor * emerald = [self colorFromRed:46 Green:204 andBlue:113];
    UIColor * nephritis = [self colorFromRed:39 Green:174 andBlue:96];
    UIColor * belize = [self colorFromRed:41 Green:128 andBlue:185];
    UIColor * peter =[self colorFromRed:52 Green:152 andBlue:219];
    UIColor * rainBlue = [self colorFromRed:0 Green:192 andBlue:228];
    UIColor * brooklynPurple = [self colorFromRed:118 Green:88 andBlue:248];
    UIColor * amethyst = [self colorFromRed:155 Green:89 andBlue:182];
    UIColor * wisteria = [self colorFromRed:142 Green:68 andBlue:173];
    UIColor * midnightBlue = [self colorFromRed:44 Green:62 andBlue:80];
    UIColor * wetAsphalt = [self colorFromRed:52 Green:73 andBlue:94];
    
    
    self.colors = @[black,
                    asbestos,
                    silver,
                    pomegranate,
                    pumpkin,
                    orange,
                    midnightBlue,
                    wisteria,
                    belize,
                    nephritis,
                    greenSea,
                    concrete,
                    clouds,
                    alizarin,
                    carrot,
                    sunflower,
                    wetAsphalt,
                    amethyst,
                    peter,
                    emerald,
                    turquoise,
                    windRed,
                    rainBlue,
                    grassGreen,
                    portlandYellow,
                    brooklynPurple,
                    ];
    
    self.lightColors = [NSSet setWithArray:@[clouds]];
    
    self.defaultColorIndex = [self.colors indexOfObject:black];
}

-(UIColor *) colorFromRed:(CGFloat)
red
                    Green:(CGFloat) green
                  andBlue:(CGFloat) blue
{
    return [UIColor colorWithRed:red/255 green:green/255 blue:blue/255 alpha:1];
}

-(NSInteger) defaultColorIndex
{
    return _defaultColorIndex;
}

-(NSSet *) getLightColors
{
    return self.lightColors;
}

-(int) numberOfColors
{
    return self.colors.count;
}

-(UIColor *) colorForIndexPath:(NSIndexPath *) indexPath
{
    int index = indexPath.item;
    return self.colors[index];
}

-(NSArray *) getAllColors
{
    return self.colors;
}

@end
