//
//  ListsCollectionRowView.m
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListsCollectionRowView.h"

#define LABEL_INSET_HOR 10
#define LABEL_INSET_VER 10
#define IMG_INSET_HOR 5
#define IMG_INSET_VER 5
#define IMG_WIDTH 70

@implementation ListsCollectionRowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        [self addBackgrounViewPlaceHolder];
        [self addImagePlaceHolder];
        [self addLabelPlaceholder];
    }
    return self;
}

-(void) addBackgrounViewPlaceHolder
{
    CGRect backgroundFrame = self.bounds;
    UIView * backGroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    backGroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backGroundView];
    self.backgroundView = backGroundView;
}

-(void) addLabelPlaceholder
{
    CGSize labelSize = CGSizeMake(self.bounds.size.width - 2 * LABEL_INSET_HOR - self.collectionImage.frame.size.width,
                                  self.bounds.size.height - 2 * LABEL_INSET_VER);
    CGPoint labelOrigin = CGPointMake(self.bounds.origin.x + LABEL_INSET_HOR + self.collectionImage.frame.size.width,
                                      LABEL_INSET_VER);
    CGRect labelFrame = CGRectMake(labelOrigin.x, labelOrigin.y,
                                   labelSize.width, labelSize.height);
    UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    [self addSubview:label];
    self.collectionLabel = label;
}

-(void) addImagePlaceHolder
{
    CGRect imgFrame = CGRectMake(self.bounds.origin.x + IMG_INSET_HOR,
                                   self.bounds.origin.y + IMG_INSET_VER,
                                   IMG_WIDTH,
                                   self.bounds.size.height - 2 * IMG_INSET_VER);
    
    UIImageView * image = [[UIImageView alloc] initWithFrame:imgFrame];
    [self addSubview:image];
    self.collectionImage = image;
}
@end
