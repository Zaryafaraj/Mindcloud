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
#define HIDE_TEXT @"Hide Text"
#define SHOW_TEXT @"Show Text"

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
    self.resizesToFitImage = YES;
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
    if (self.resizesToFitImage)
    {
        [self resizeNoteToMatchImageSize];
    }
    
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
    if (!CGAffineTransformIsIdentity(self.transform))
    {
        self.transform = CGAffineTransformIdentity;
    }
    
    [super setFrame:frame];
    [self adjustSubViewsForPropertyChangeInImage];
}

-(void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self adjustSubViewsForPropertyChangeInImage];
}

-(void) adjustSubViewsForPropertyChangeInImage
{
    if (self.imageView)
    {
        self.imageView.frame = CGRectMake(0,
                                          0,
                                          self.bounds.size.width,
                                          self.bounds.size.height);
    }
    if (self.placeHolderView)
    {
        self.placeHolderView.frame = CGRectMake(0,
                                                0,
                                                self.bounds.size.width,
                                                self.bounds.size.height);
    }
    //if there is a control view resize everything so that control view is at the bottom
    if (self.isControlViewShowing)
    {
        self._textView.frame = CGRectMake(self._textView.frame.origin.x,
                                          self._textView.frame.origin.y,
                                          self._textView.bounds.size.width,
                                          self._textView.bounds.size.height - EXTENDED_EDGE_SIZE);
        
        self.imageView.frame = CGRectMake(self.imageView.bounds.origin.x,
                                          self.imageView.bounds.origin.y,
                                          self.imageView.bounds.size.width,
                                          self.imageView.bounds.size.height - EXTENDED_EDGE_SIZE);
        
        if (self.placeHolderView)
        {
            self.placeHolderView.frame = self.imageView.frame;
        }
        
        CGRect controlViewFrame = CGRectMake(self.imageView.frame.origin.x,
                                             self.imageView.frame.origin.y + self.imageView.frame.size.height,
                                             self.imageView.frame.size.width,
                                             EXTENDED_EDGE_SIZE);
        self.controlView.frame = controlViewFrame;
        [self layoutControlElements];
    }
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
    CGRect extendedBounds = CGRectMake(self.bounds.origin.x,
                                      self.bounds.origin.y,
                                      self.bounds.size.width,
                                      self.bounds.size.height + EXTENDED_EDGE_SIZE);
    self.bounds = extendedBounds;;
    
    //move the text frame, image view and place holder up
    self._textView.frame = CGRectMake(self._textView.frame.origin.x,
                                      self._textView.frame.origin.y,
                                      self._textView.bounds.size.width,
                                      self._textView.bounds.size.height - EXTENDED_EDGE_SIZE);
    
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x,
                                      self.imageView.frame.origin.y,
                                      self.imageView.bounds.size.width,
                                      self.imageView.bounds.size.height - EXTENDED_EDGE_SIZE);
    
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
    button.tintColor = [[ThemeFactory currentTheme] tintColor];
    [button setTitle: HIDE_TEXT forState:UIControlStateNormal];
    [button addTarget:self action:@selector(togglePressed:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:button];
    [button sizeToFit];
    button.frame = CGRectMake(controlView.frame.size.width/2 - button.frame.size.width/2,
                              5,
                              button.frame.size.width,
                              button.frame.size.height);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    return controlView;
}

-(void) layoutControlElements
{
    //one day I should use autolayout programatically here to center it automatically
   if (self.controlView)
   {
       NSArray * subViews = self.controlView.subviews;
       if (subViews != nil && [subViews count] != 0)
       {
           UIButton * hideButton = subViews[0];
           hideButton.frame = CGRectMake(self.controlView.frame.size.width/2 - hideButton.frame.size.width/2,
                                     5,
                                     hideButton.frame.size.width,
                                     hideButton.frame.size.height);
           hideButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
       }
   }
}

-(void) togglePressed:(UIButton *) sender
{
    if ([sender.titleLabel.text isEqualToString:HIDE_TEXT])
    {
        //We just hide the place holder and text View
        self._textView.hidden = YES;
        self.placeHolderView.hidden = YES;
        [sender setTitle:SHOW_TEXT forState:UIControlStateNormal];
        [sender sizeToFit];
        
    }
    else if ([sender.titleLabel.text isEqualToString:SHOW_TEXT])
    {
        self._textView.hidden = NO;
        self.placeHolderView.hidden = NO;
        [sender setTitle:HIDE_TEXT forState:UIControlStateNormal];
        [sender sizeToFit];
    }
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

-(void) hideAllControllerButtons
{
    if (self.controlView)
    {
        for(UIView * view in self.controlView.subviews)
        {
            view.hidden = YES;
        }
    }
}

-(void) hidePlaceholder
{
    if (self.placeHolderView)
    {
        [self hideAllControllerButtons];
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
                weakSelf.controlView.alpha = 0;
                
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

-(void) resizeToRect:(CGRect)rect Animate:(BOOL)animate
{
    [super resizeToRect:rect Animate:animate];
    //self.imageView.contentMode =  UIViewContentModeTopLeft;
    self.frame = super.frame;
}
-(void) resetSize
{
    [super resetSize];
    [self resizeNoteToMatchImageSize];
    
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
