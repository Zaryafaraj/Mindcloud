//
//  CollectionCell.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ThemeFactory.h"

@interface CollectionCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picImage;
@property (weak, nonatomic) IBOutlet UIImageView * addPlaceholderImage;
@property (weak, nonatomic) IBOutlet UIView *titleBackground;
@property BOOL isShrunken;
@property (nonatomic) UIButton * deleteButton;

@end
@implementation CollectionCell

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        //        bgView.backgroundColor = [UIColor clearColor];
        self.picImage.backgroundColor = [[ThemeFactory currentTheme] backgroundColorForEmptyCollectoinCell];
        //        bgView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        //        bgView.layer.borderWidth = 3;
        //        self.selectedBackgroundView = bgView;
        UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(collectionSelected:)];
        lpgr.minimumPressDuration = 0.3;
        [self addGestureRecognizer:lpgr];
    }
    return self;
}

-(UIButton *) deleteButton
{
    
    if (!_deleteButton)
    {
        UIButton * delButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _deleteButton = delButton;
        [_deleteButton addTarget:self
                          action:@selector(deletePressed:)
                forControlEvents:UIControlEventTouchDown];
        
        UIImage * btnImage = [[ThemeFactory currentTheme] imageForDeleteIcon];
        [_deleteButton setImage:btnImage
                       forState:UIControlStateNormal];
        [self addSubview:_deleteButton];
        _deleteButton.frame = CGRectMake(self.frame.origin.x - 10, self.frame.origin.y - 10, 44, 44);
        
        [self.superview addSubview:_deleteButton];
        _deleteButton.tintColor = [[ThemeFactory currentTheme] tintColorForDeleteIcon];
        _deleteButton.alpha = 0;
    }
    return _deleteButton;
}


-(void) deletePressed:(id)sender
{
    
    id<CollectionCellDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel deletePressed:self];
    }
}

-(void) collectionSelected:(UILongPressGestureRecognizer *) gr
{
    if (gr.state == UIGestureRecognizerStateBegan)
    {
        id<CollectionCellDelegate> tempDel = self.delegate;
        if (tempDel)
        {
            [tempDel cellLongPressed:self];
        }
    }
}

-(void) setText:(NSString *)text
{
    _text = text;
    _titleLabel.text = text;
}

-(void) setImg:(UIImage *)img
{
    _img = img;
    _picImage.image = img;
    
    self.picImage.backgroundColor = [[ThemeFactory currentTheme] backgroundColorForEmptyCollectoinCell];
}


-(void) setPlaceholderForAdd:(BOOL)placeholderForAdd
{
    _placeholderForAdd = placeholderForAdd;
    if (placeholderForAdd)
    {
        self.addPlaceholderImage.hidden = NO;
        self.addPlaceholderImage.image = [[ThemeFactory currentTheme] imageForAddCollection];
        self.addPlaceholderImage.tintColor = [[ThemeFactory currentTheme] tintColorForAddCollectionIcon];
        //[UIColor blueColor];
        self.picImage.image = nil;
        self.img = nil;
        self.picImage.image = nil;
        self.picImage.backgroundColor = [[ThemeFactory currentTheme] backgroundColorFoAddCollectionCell];
        self.titleLabel.hidden = YES;
        self.titleBackground.hidden = YES;
    }
    else
    {
        self.addPlaceholderImage.hidden = YES;
        self.picImage.backgroundColor = [[ThemeFactory currentTheme] backgroundColorForEmptyCollectoinCell];
        self.titleLabel.hidden = NO;
        self.titleBackground.hidden = NO;
    }
}

-(void) setIsInSelectMode:(BOOL)isInSelectMode
{
    _isInSelectMode = isInSelectMode;
    
    if (isInSelectMode)
    {
        self.transform = CGAffineTransformScale(self.transform, 1.1, 1.1);
    }
    else
    {
        self.transform = CGAffineTransformIdentity;
    }
}
-(void) setIsInSelectMode:(BOOL)isInSelectMode
                 animated:(BOOL) animated
{
    _isInSelectMode = isInSelectMode;
    if (animated)
    {
        if (isInSelectMode)
        {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.transform = CGAffineTransformScale(self.transform, 1.1, 1.1);
                                 
                             }completion:^(BOOL completed){}];
        }
        else
        {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 
                                 self.transform = CGAffineTransformIdentity;
                                 
                             }completion:^(BOOL completed){}];
            
        }
    }
    else
    {
        self.isInSelectMode = YES;
    }
    
}

-(void) shrink:(BOOL) animated
{
    if (!self.isShrunken)
    {
        if (animated)
        {
            self.deleteButton.alpha = 0;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.deleteButton.alpha = 1;
                                 self.transform = CGAffineTransformScale(self.transform, 0.95, 0.95);
                             }completion:^(BOOL completed){
                             }];
            
        }
        else
        {
            
            self.transform = CGAffineTransformScale(self.transform, 0.95, 0.95);
            self.deleteButton.alpha = 1;
        }
        self.isShrunken = YES;
    }
}

-(void) unshrink:(BOOL) animated
{
    if (self.isShrunken)
    {
        
        if (animated)
        {
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.transform = CGAffineTransformIdentity;
                                 self.deleteButton.alpha = 0;
                             }completion:nil];
            
        }
        else
        {
            
            self.transform = CGAffineTransformIdentity;
            self.deleteButton.alpha = 0;
        }
        self.isShrunken = NO;
    }
}

-(void) reset
{
    [self.deleteButton removeFromSuperview];
    self.deleteButton = nil;
    self.isShrunken = NO;
    self.transform = CGAffineTransformIdentity;
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
