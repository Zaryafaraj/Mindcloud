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

@interface ListsCollectionRowView()

@property (readwrite) BOOL isOpen;

@end
@implementation ListsCollectionRowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        [self addBackgroundLayer];
        [self addforgroundLayer];
        [self addGestureRecognizers];
    }
    return self;
}

-(void) swippedLeft:(UISwipeGestureRecognizer *) sender
{
    NSLog(@"Swipped Left");
    if (sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded)
    {
        [self closeView];
    }
}

-(void) swippedRight:(UISwipeGestureRecognizer *) sender
{
    NSLog(@"Swipped Right");
    if (sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded)
    {
        [self openView];
    }
}

-(void) tapped:(UISwipeGestureRecognizer *) sender
{
    NSLog(@"Tapped");
}

-(void) openView
{
    if (!self.isOpen)
    {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.foregroundView.frame = CGRectMake(self.foregroundView.frame.origin.x + self.foregroundView.frame.size.width/3,
                                                                    self.foregroundView.frame.origin.y,
                                                                    self.foregroundView.frame.size.width - self.foregroundView.frame.size.width/3,
                                                                    self.foregroundView.frame.size.height);
                         }completion:nil];
        self.isOpen = YES;
    }
}

-(void) closeView
{
    if (self.isOpen)
    {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.foregroundView.frame = self.bounds;
                         }completion:nil];
        self.isOpen = NO;
    }
}

-(void) addforgroundLayer
{
    CGRect foregroundFrame = self.bounds;
    UIView * foregroundView = [[UIView alloc] initWithFrame:foregroundFrame];
    foregroundView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:foregroundView];
    self.foregroundView = foregroundView;
    [self addImagePlaceHolder];
    [self addLabelPlaceholder];
}

-(void) addBackgroundLayer
{
    CGRect backgroundFrame = self.bounds;
    UIView * backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backgroundView];
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
    
    [self.foregroundView addSubview:label];
    self.collectionLabel = label;
}

-(void) addImagePlaceHolder
{
    CGRect imgFrame = CGRectMake(self.bounds.origin.x + IMG_INSET_HOR,
                                 self.bounds.origin.y + IMG_INSET_VER,
                                 IMG_WIDTH,
                                 self.bounds.size.height - 2 * IMG_INSET_VER);
    
    UIImageView * image = [[UIImageView alloc] initWithFrame:imgFrame];
    
    [self.foregroundView addSubview:image];
    self.collectionImage = image;
}

-(void) addGestureRecognizers
{
    self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    UISwipeGestureRecognizer * lsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swippedLeft:)];
    lsgr.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer * rsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swippedRight:)];
    rsgr.direction = UISwipeGestureRecognizerDirectionRight;
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tgr requireGestureRecognizerToFail:lsgr];
    [tgr requireGestureRecognizerToFail:rsgr];
    [self addGestureRecognizer:lsgr];
    [self addGestureRecognizer:rsgr];
    [self addGestureRecognizer:tgr];
    
}
@end
