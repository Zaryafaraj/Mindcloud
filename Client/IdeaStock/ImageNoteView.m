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
#define EXTENDED_EDGE_SIZE 40

@interface ImageNoteView()

@property UIImageView * imageView;
@property UIView * placeHolderView;
@property UIView * controlView;
@property BOOL isControlViewShowing;

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
    if (self.isControlViewShowing)
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
    newImageView.backgroundColor = self.imageView.backgroundColor;
    newImageView.alpha = self.imageView.alpha;
    prototype = [super _configurePrototype:prototype];
    prototype._textView.text = @"";
    return prototype;
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
        self.isControlViewShowing = YES;
        
    }
}

-(UIView *) createControlView
{
    CGRect controlViewFrame = CGRectMake(self.imageView.frame.origin.x,
                                         self.imageView.frame.origin.y + self.imageView.frame.size.height,
                                         self.imageView.frame.size.width,
                                         EXTENDED_EDGE_SIZE);
    UIView * controlView = [[UIView alloc] initWithFrame:controlViewFrame];
    controlView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    controlView.alpha = 0;
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.hidden = NO;
    button.titleLabel.text = @"aklsjdalksjdlkajsdlkajslkdjalksdjas";
    //I have no idea why the title hidden property gets set to YES when button is initiated
    button.frame = CGRectMake(5, 5, 100, 30);
    button.tintColor = [[ThemeFactory currentTheme] tintColor];
    [button setTitle:@"Hide Text" forState:UIControlStateNormal];
    [controlView addSubview:button];
    return controlView;
}

-(void) showPlaceHolder
{
    if (self.placeHolderView == nil)
    {
        if (!self.isControlViewShowing)
        {
            [self extendView];
        }
        self.placeHolderView = [[UIView alloc] initWithFrame:self.imageView.frame];
        self.placeHolderView.backgroundColor = [UIColor whiteColor];
        self.placeHolderView.alpha = 0.0;
        [self insertSubview:self.placeHolderView belowSubview:self._textView];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.placeHolderView.alpha = 0.7;
            self.controlView.alpha = 1;
        }];
    }
}

-(void) hidePlaceholder
{
    if (self.placeHolderView)
    {
        __weak ImageNoteView * weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.placeHolderView.alpha = 0;
            
            if (self.isControlViewShowing)
            {
                weakSelf.isControlViewShowing = NO;
                weakSelf.frame = CGRectMake(self.frame.origin.x,
                                            self.frame.origin.y,
                                            self.frame.size.width,
                                            self.frame.size.height - EXTENDED_EDGE_SIZE);
                
            }
        }completion:^(BOOL finished){
            [weakSelf.placeHolderView removeFromSuperview];
            weakSelf.placeHolderView = nil;
            [weakSelf.controlView removeFromSuperview];
            weakSelf.controlView = nil;
        }];
    }
}
-(void) textViewDidBeginEditing:(UITextView *)textView
{
    [self showPlaceHolder];
    [super textViewDidBeginEditing:textView];
}

-(void) textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        if (self.placeHolderView) [self hidePlaceholder];
    }
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
@end
