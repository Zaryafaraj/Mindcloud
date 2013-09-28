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
#define EXTENDED_EDGE_SIZE 50

@interface ImageNoteView()

@property UIImageView * imageView;
@property UIView * placeHolderView;
@property UIButton * toggleButton;
@property UIView * controlView;

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
    //if there is a control view resize everything so that control view is at the bottom
    if (self.controlView)
    {
        self._textView.frame = CGRectMake(self._textView.frame.origin.x,
                                          self._textView.frame.origin.y,
                                          self._textView.frame.size.width,
                                          self._textView.frame.size.height - EXTENDED_EDGE_SIZE);
        
        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,
                                          self.imageView.frame.origin.y,
                                          self.imageView.frame.size.width,
                                          self.imageView.frame.size.height - EXTENDED_EDGE_SIZE);
        
        if (self.placeHolderView)
        {
            self.placeHolderView.frame = self.imageView.frame;
        }
        
        CGRect controlViewFrame = CGRectMake(self.imageView.frame.origin.x,
                                             self.imageView.frame.origin.y + self.imageView.frame.size.height,
                                             self.imageView.frame.size.width,
                                             EXTENDED_EDGE_SIZE);
        self.controlView.frame = controlViewFrame;
    }
    
    if(self.toggleButton)
    {
        
        CGFloat buttonOriginX = frame.size.width - 50  - INFO_BUTTON_OFFSET_X ;
        CGFloat buttonOriginY = frame.size.height - 50 - INFO_BUTTON_OFFSET_Y;
        
        self.toggleButton.frame = CGRectMake(buttonOriginX,
                                             buttonOriginY,
                                             50,
                                             50);
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
    UIButton * newButton = [self createToggleButton];
    prototype.toggleButton = newButton;
    prototype.toggleButton.hidden = YES;
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
        [self hidePlaceholder];
    }
    else if (![textView.text isEqualToString:@""] &&
             self.placeHolderView == nil)
    {
        [self showPlaceHolder];
    }
}

-(UIButton *) createToggleButton
{
    UIButton * newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    newButton.titleLabel.text = @"Hide Text";
    CGFloat buttonOriginX = self.frame.size.width - 50 - INFO_BUTTON_OFFSET_X;
    CGFloat buttonOriginY = self.frame.size.height - 50 - INFO_BUTTON_OFFSET_Y;
    newButton.frame = CGRectMake(buttonOriginX,
                                 buttonOriginY,
                                 50,
                                 50);
    newButton.tintColor = [UIColor blackColor];
    return newButton;
}

-(void) extendView
{
    CGRect extendedFrame = CGRectMake(self.frame.origin.x,
                                      self.frame.origin.y,
                                      self.frame.size.width,
                                      self.frame.size.height + EXTENDED_EDGE_SIZE);
    self.frame = extendedFrame;
    
    //move the text frame, image view and place holder up
    self._textView.frame = CGRectMake(self._textView.frame.origin.x,
                                      self._textView.frame.origin.y,
                                      self._textView.frame.size.width,
                                      self._textView.frame.size.height - EXTENDED_EDGE_SIZE);
    
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,
                                      self.imageView.frame.origin.y,
                                      self.imageView.frame.size.width,
                                      self.imageView.frame.size.height - EXTENDED_EDGE_SIZE);
    
    if (self.placeHolderView)
    {
        self.placeHolderView.frame = self.imageView.frame;
    }
    
    //now add the UIView for placeholder to the end
    if (self.controlView == nil)
    {
        UIView * controlView = [self createControlView];
        [self addSubview:controlView];
        self.controlView = controlView;
        
    }
}

-(void) hideControlView
{
    [self.controlView removeFromSuperview];
    self.controlView = nil;
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height - EXTENDED_EDGE_SIZE);
}

-(UIView *) createControlView
{
    CGRect controlViewFrame = CGRectMake(self.imageView.frame.origin.x,
                                         self.imageView.frame.origin.y + self.imageView.frame.size.height,
                                         self.imageView.frame.size.width,
                                         EXTENDED_EDGE_SIZE);
    UIView * controlView = [[UIView alloc] initWithFrame:controlViewFrame];
    controlView.backgroundColor = [[ThemeFactory currentTheme] tintColor];
    return controlView;
}

-(void) showPlaceHolder
{
    if (self.placeHolderView == nil)
    {
        [self extendView];
        self.placeHolderView = [[UIView alloc] initWithFrame:self.imageView.frame];
        self.placeHolderView.backgroundColor = [UIColor whiteColor];
        self.placeHolderView.alpha = 0.0;
        [self insertSubview:self.placeHolderView belowSubview:self._textView];
        
        if (self.toggleButton == nil)
        {
            UIButton * newButton = [self createToggleButton];
            self.toggleButton = newButton;
            [self insertSubview:newButton aboveSubview:self.imageView];
        }
        
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

-(void) hidePlaceholder
{
    if (self.placeHolderView && self.toggleButton)
    {
        [self hideControlView];
        [UIView animateWithDuration:0.3 animations:^{
            self.placeHolderView.alpha = 0;
            self.toggleButton.alpha = 0;
        }completion:^(BOOL finished){
            [self.placeHolderView removeFromSuperview];
            self.placeHolderView = nil;
            [self.toggleButton removeFromSuperview];
            self.toggleButton = nil;
        }];
    }
}
-(void) textViewDidBeginEditing:(UITextView *)textView
{
    [self showPlaceHolder];
    [super textViewDidBeginEditing:textView];
}
@end
