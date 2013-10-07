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
    UIColor *aColor = [UIColor colorWithHue:0.602 saturation:0.663 brightness:0.792 alpha:1.000];
    return aColor;
}

-(UIColor *) collectionBackgroundColor
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"signin_backgroun_pattern"]];
    //return [UIColor colorWithPatternImage:[UIImage imageNamed:@"signin_backgroun_pattern"]];
}

-(UIColor *) backgroundColorForAllCollectionCategory
{
    UIColor *aColor = [UIColor colorWithHue:0.383 saturation:0.656 brightness:0.882 alpha:1.000];
    return  aColor;
}

-(UIColor *) backgroundColorForUncategorizedCategory
{
    return nil;
}

-(UIColor *) backgroundColorForSharedCategory
{
    return nil;
}

@end
