//
//  BlueTheme.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/27/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "BlueTheme.h"

@implementation BlueTheme

-(UIColor *) tintColor
{
   UIColor *aColor = [UIColor colorWithHue:0.627 saturation:0.574 brightness:0.921 alpha:1.000];
    return aColor;
}

-(UIColor *) collectionBackgroundColor
{
    return [UIColor colorWithRed:227
                           green:227
                            blue:227
                           alpha:1];
//    [UIColor colorWithPatternImage:[UIImage imageNamed:@"CollectionBigBackgroud"]];
    //[UIColor colorWithPatternImage:[UIImage imageNamed:@"signin_backgroun_pattern"]];
}

-(UIColor *) backgroundColorForAllCollectionCategory
{
    UIColor *aColor = [UIColor colorWithHue:0.383 saturation:0.600 brightness:0.782 alpha:1.000];
    return  aColor;
}

-(UIColor *) backgroundColorForUncategorizedCategory
{
    UIColor *aColor = [UIColor colorWithHue:0.765 saturation:0.476 brightness:0.800 alpha:1.000];
    return aColor;
}

-(UIColor *) backgroundColorForSharedCategory
{
    UIColor *aColor = [UIColor colorWithHue:0.061 saturation:0.775 brightness:0.950 alpha:1.000];;
    return aColor;
}

-(UIColor *) backgroundColorForCustomCategory
{
    UIColor *aColor = [UIColor colorWithHue:0.006 saturation:0.576 brightness:1.000 alpha:1.000];
    return aColor;
}

-(UIColor *) defaultColorForDrawing
{
    UIColor * white =[UIColor colorWithHue:0.000 saturation:0.000 brightness:0.971 alpha:1.000];
    return white;
}

-(UIColor *) noisePatternForCollection
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"noisy-collection-transparent"]];
}

-(UIColor *) navigationBarButtonItemColor
{
    return [UIColor colorWithWhite:0.18 alpha:1];
}

@end
