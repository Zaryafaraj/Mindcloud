//
//  ImageView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 5/27/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "ImageNoteView.h"
#import "CollectionAnimationHelper.h"
#import "ThemeFactory.h"

#define INFO_BUTTON_OFFSET_X 10
#define INFO_BUTTON_OFFSET_Y 10

@interface ImageNoteView()

@property UIImageView * imageView;
@property UIView * placeHolderView;
@property UIButton * toggleButton;

@end

@implementation ImageNoteView

@synthesize image = _image;
@synthesize imageView = _imageView;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self configureImageView];
    }
    return self;
}

-(void) configureImageView
{
    //find the text view
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UIImageView class]])
        {
            self.imageView = (UIImageView *) subView;
            self.text = @"";
            break;
        }
    }
}

-(void) setImage:(UIImage *)image
{
    _image = image;
    [self resizeNoteToMatchImageSize];
    [self.imageView setImage:image];
}

-(UIImage *) image
{
    return _image;
}

-(void) resizeNoteToMatchImageSize
{
    if (self.image)
    {
        CGFloat imageWidth = self.image.size.width;
        CGFloat imageHeight = self.image.size.height;
        CGFloat newNoteHeight = (self.frame.size.width * imageHeight) / imageWidth;
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                newNoteHeight);
    }
}

-(void) setText:(NSString *)text
{
    [super setText:text];
    if (![self._textView.text isEqualToString:@""])
    {
        [self showPlaceHolder];
    }
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self.imageView)
    {
        self.imageView.frame = CGRectMake(0,
                                          0,
                                          frame.size.width,
                                          frame.size.height);
    }
    if (self.placeHolderView)
    {
        self.placeHolderView.frame = CGRectMake(0,
                                                0,
                                                frame.size.width,
                                                frame.size.height);
    }
    
    if(self.toggleButton)
    {
        
        CGFloat buttonOriginX = frame.size.width - self.toggleButton.frame.size.width - INFO_BUTTON_OFFSET_X ;
        CGFloat buttonOriginY = frame.size.height - self.toggleButton.frame.size.height - INFO_BUTTON_OFFSET_Y;
        
        self.toggleButton.frame = CGRectMake(buttonOriginX,
                                     buttonOriginY,
                                     self.toggleButton.frame.size.width,
                                     self.toggleButton.frame.size.height);
    }
}

-(void) scaleWithScaleOffset:(CGFloat)scaleOffset animated:(BOOL)animated
{
    [super scaleWithScaleOffset:scaleOffset animated:YES];
    self.frame = super.frame;
}

-(void) scale:(CGFloat) scaleFactor animated:(BOOL)animated{
    
    [super scale:scaleFactor animated:animated];
    self.frame = super.frame;
}

-(void) resetSize
{
    [super resetSize];
    self.frame = super.frame;
}


-(void)resizeToRect:(CGRect)rect Animate:(BOOL)animate
{
    [super resizeToRect:rect Animate:animate];
    self.frame = super.frame;
}

-(instancetype) prototype
{
    ImageNoteView * prototype = [[ImageNoteView alloc] initWithFrame:self.frame];
    UIImageView * newImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    [prototype addSubview:newImageView];
    prototype.imageView = newImageView;
    UIButton * newButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    CGFloat buttonOriginX = self.bounds.size.width - newButton.frame.size.width - INFO_BUTTON_OFFSET_X;
    CGFloat buttonOriginY = self.bounds.size.width - newButton.frame.size.height - INFO_BUTTON_OFFSET_Y;
    newButton.frame = CGRectMake(buttonOriginX,
                                 buttonOriginY,
                                 newButton.frame.size.width,
                                 newButton.frame.size.height);
    prototype.toggleButton = newButton;
    prototype.toggleButton.tintColor = [UIColor blackColor];
    newButton.hidden = YES;
    [prototype addSubview:newButton];
    
    newImageView.backgroundColor = self.imageView.backgroundColor;
    newImageView.alpha = self.imageView.alpha;
    prototype = [super _configurePrototype:prototype];
    prototype._textView.text = @"";
    return prototype;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""] &&
        self.placeHolderView != nil)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.placeHolderView.alpha = 0;
        }completion:^(BOOL finished){
            [self.placeHolderView removeFromSuperview];
            self.placeHolderView = nil;
        }];
    }
    else if (![textView.text isEqualToString:@""] &&
             self.placeHolderView == nil)
    {
        [self showPlaceHolder];
    }
}

-(void) showPlaceHolder
{
    if (self.placeHolderView == nil)
    {
        self.placeHolderView = [[UIView alloc] initWithFrame:self.imageView.frame];
        self.placeHolderView.backgroundColor = [UIColor whiteColor];
        self.placeHolderView.alpha = 0.0;
        [self insertSubview:self.placeHolderView belowSubview:self._textView];
        self.toggleButton.alpha = 0;
        self.toggleButton.hidden = NO;
        [self.toggleButton removeFromSuperview];
        [self addSubview:self.toggleButton];
        [UIView animateWithDuration:0.3 animations:^{
        self.placeHolderView.alpha = 0.7;
        self.toggleButton.alpha = 0.7;
           }];
    }
    
}

-(void) textViewDidBeginEditing:(UITextView *)textView
{
    [self showPlaceHolder];
    [super textViewDidBeginEditing:textView];
}
@end
