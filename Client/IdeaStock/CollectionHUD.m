//
//  CollectionHUD.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionHUD.h"

@interface CollectionHUD()

@property (nonatomic, strong) UILabel * label;
@property (nonatomic, strong) UIImageView * image;

@end
@implementation CollectionHUD

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    return self;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
}
-(void) configureView
{
    self.backgroundColor = [UIColor colorWithWhite:0.02 alpha:0.5];
    self.layer.cornerRadius = 15;
    
    UILabel * label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    label.hidden = NO;
    self.label = label;
    [self addSubview:label];
    
    NSLayoutConstraint * labelX = [NSLayoutConstraint constraintWithItem:label
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    
    NSLayoutConstraint * labelY = [NSLayoutConstraint constraintWithItem:label
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    
    UIImageView * image = [[UIImageView alloc] init];
    [self addSubview:image];
    image.translatesAutoresizingMaskIntoConstraints = NO;
    image.hidden = YES;
    self.image = image;
    NSLayoutConstraint * imageX = [NSLayoutConstraint constraintWithItem:image
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    
    NSLayoutConstraint * imageY = [NSLayoutConstraint constraintWithItem:image
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1
                                                                constant:0];
    
    NSLayoutConstraint * imageWidth = [NSLayoutConstraint constraintWithItem:image
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:0.5
                                                                    constant:0];
    
    NSLayoutConstraint * imageHeight = [NSLayoutConstraint constraintWithItem:image
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0.5
                                                                    constant:0];
    
    NSArray * constraints = @[labelX, labelY, imageX, imageY, imageWidth, imageHeight];
    [self addConstraints:constraints];
    
}


-(void) setTitleText:(NSString *) text
{
    self.image.hidden = YES;
    self.label.hidden = NO;
    self.label.text = text;
}

-(void) setTitleImage:(UIImage *) image
{
    self.image.hidden = NO;
    self.label.hidden = YES;
    self.image.image = image;
    self.image.tintColor = [UIColor whiteColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
