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
    UIColor * aColor =[UIColor blackColor];
    return aColor;
}

-(UIColor *) noisePatternForCollection
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"noisy-collection-transparent"]];
}

-(UIColor *) navigationBarButtonItemColor
{
    return [UIColor colorWithWhite:0.18 alpha:1];
}

-(UIColor *) colorForPaintControl
{
    return [self tintColor];
    //return [UIColor colorWithHue:0.975 saturation:1.000 brightness:0.974 alpha:1.000];
}

-(UIImage *) imageForPaintControl
{
    UIImage * img = [UIImage imageNamed:@"paint-control-icon"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIImage *) imageForPaintControlEraser
{
    UIImage * img = [UIImage imageNamed:@"paint-control-eraser"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIImage *) iconForUndoControl
{
    UIImage * img = [UIImage imageNamed:@"undo-round"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIImage *) iconForRedoControl
{
    UIImage * img = [UIImage imageNamed:@"redo-round"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIImage *) iconForPaintControl
{
    UIImage * img = [UIImage imageNamed:@"paint-round"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIImage *) iconForClearControl
{
    UIImage * img = [UIImage imageNamed:@"clear-round"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIImage *) iconForEraseControl
{
    UIImage * img = [UIImage imageNamed:@"eraser-round"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIColor *) tintColorForActivePaintControl
{
    return [UIColor whiteColor];
}

-(UIColor *) tintColorForInactivePaintControl
{
    
    return [UIColor colorWithWhite:1.0 alpha:0.5];
}

-(UIColor *) tintColorForActivePaintControlButton
{
    return [self tintColor];
}

-(UIColor *) tintColorForInactivePaintControlButton
{
    return [UIColor darkGrayColor];
}

-(UIImage *) imageForDeleteIcon
{
    
    UIImage * img = [UIImage imageNamed:@"delete-round"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIColor *) tintColorForDeleteIcon
{
    return [UIColor colorWithWhite:0.20 alpha:1.0];
}

-(UIColor *) tintColorForIconsInStack
{
    return [UIColor colorWithWhite:0.10 alpha:1.0];
}

-(UIImage *) imageForUndo
{
    UIImage * img = [UIImage imageNamed:@"undo"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIImage *) imageForRedo
{
    UIImage * img = [UIImage imageNamed:@"redo"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIColor *) colorForImageNoteTextPlaceholder
{
    return [UIColor colorWithWhite:0.9 alpha:0.9];
}

-(UIImage *) imageForExpand
{
    UIImage * img = [UIImage imageNamed:@"expand-round"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIImage *) imageForUnstack
{
    //UIImage * img = [UIImage imageNamed:@"unstack-round"];
    UIImage * img = [UIImage imageNamed:@"unstack-round-v2"];
    return [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(UIColor *) backgroundColorForStackController
{
    
    //UIColor *aColor = [UIColor colorWithHue:0.627 saturation:0.574 brightness:0.921 alpha:0.85];
    UIColor * bgColor = [UIColor colorWithWhite:0.36 alpha:0.95];
    return bgColor;
}

@end
