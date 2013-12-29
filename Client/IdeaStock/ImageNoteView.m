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

@interface ImageNoteView()

@property UIImageView * imageView;
@property UIView * noteView;
@property UITextView * placeHolderTextview;
@property UIView * toggleView;
@property UIView * placeholderView;

@property NSLayoutConstraint * placeholderHeightConstraintOpen;
@property NSLayoutConstraint * placeholderHeightConstraintClose;

@property BOOL isTextShowing;

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
    self.isTextShowing = YES;
    self.resizesToFitImage = YES;
    //find the text view
    UIView * noteView = self.subviews.firstObject;
    self.noteView = noteView;
    for (UIView * subView in self.noteView.subviews){
        if ([subView isKindOfClass:[UIImageView class]])
        {
            self.imageView = (UIImageView *) subView;
            self.text = @"";
            continue;
        }
        else if ([subView isKindOfClass:[UITextView class]])
        {
            [subView removeFromSuperview];
        }
    }
    [self configurePlaceholder];
    
}

#define GOLDEN_RATIO_INVERSE 0.382
#define TEXT_OFFSET @"10"
#define TOGGLE_VIEW_WIDTH @"50"
#define TOGGLE_VIEW_HEIGHT @"40"
#define MAX_TOGGLE_OFFSET_FROM_TOP 40

-(void) configurePlaceholder
{
    
    UIView * placeholderView = [[UIView alloc] init];
    placeholderView.backgroundColor = [[ThemeFactory currentTheme] colorForImageNoteTextPlaceholder];
    placeholderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.placeholderView = placeholderView;
    
    UITextView * textView = [[UITextView alloc] init];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.backgroundColor = [UIColor clearColor];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.placeHolderTextview = textView;
    self.placeHolderTextview.delegate = self;
    
    [placeholderView addSubview:textView];
    
    
    NSDictionary * textViewDic = NSDictionaryOfVariableBindings(textView);
    NSDictionary * metrics = @{@"textOffset" : TEXT_OFFSET};
    
    NSString * textViewConstraintH = @"H:|-textOffset-[textView]-textOffset-|";
    NSString * textViewConstraintV = @"V:|-textOffset-[textView]-textOffset-|";
    
    [placeholderView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:textViewConstraintH
                                                                            options:0
                                                                            metrics:metrics
                                                                              views:textViewDic]];
    
    NSArray * textViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:textViewConstraintV
                                                                                    options:0
                                                                                    metrics:metrics
                                                                                      views:textViewDic];
    
    for(NSLayoutConstraint * constraint in textViewVerticalConstraints)
    {
        constraint.priority = UILayoutPriorityDefaultLow;
    }
    
    [placeholderView addConstraints:textViewVerticalConstraints];
    
    NSLayoutConstraint * placeholderWidth = [NSLayoutConstraint constraintWithItem:placeholderView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.noteView
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1
                                                                          constant:0];
    
    NSLayoutConstraint * placeholderHeightOpen = [NSLayoutConstraint constraintWithItem:placeholderView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.noteView
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:GOLDEN_RATIO_INVERSE
                                                                          constant:0];
    
    
    NSLayoutConstraint * placeholderHeightClose = [NSLayoutConstraint constraintWithItem:placeholderView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.noteView
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:0
                                                                          constant:0];
    self.placeholderHeightConstraintOpen = placeholderHeightOpen;
    self.placeholderHeightConstraintClose = placeholderHeightClose;
    
    UIView * toggleView = [[UIView alloc] init];
    toggleView.translatesAutoresizingMaskIntoConstraints = NO;
    toggleView.backgroundColor = placeholderView.backgroundColor;
    self.toggleView = toggleView;
    
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTapped:)];
//    UIPanGestureRecognizer * pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(togglePanned:)];
    
    [toggleView addGestureRecognizer:tgr];
//    [toggleView addGestureRecognizer:pgr];
    
    //[[ThemeFactory currentTheme] colorForImageNoteTextPlaceholder];
    
    [self.noteView addSubview:toggleView];
    NSDictionary * noteMetric = @{@"toggleViewWidth" : TOGGLE_VIEW_WIDTH,
                                  @"toggleViewHeight" : TOGGLE_VIEW_HEIGHT};
    
    NSArray * constraints = @[placeholderWidth, placeholderHeightOpen];
    
    NSString * placeholderConstraintsH = @"H:|-0-[placeholderView]-0-|";
    NSString * toggleConstraint = @"H:[toggleView(==toggleViewWidth)]-0-|";
    NSString * constraintsV = @"V:[toggleView(==toggleViewHeight)]-0-[placeholderView]-0-|";
    NSString * toggleViewConstraintV = @"V:|->=0-[toggleView]->=0-|";
    NSString * placeholderConstraintV = @"V:|->=0-[placeholderView]->=0-|";
    
    NSDictionary * views = NSDictionaryOfVariableBindings(placeholderView, toggleView);
    
    
    [self.noteView addSubview:placeholderView];
    
    [self.noteView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:placeholderConstraintsH
                                                                 options:0
                                                                 metrics:noteMetric
                                                                   views:views]];
    
    [self.noteView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:toggleConstraint
                                                                 options:0
                                                                 metrics:noteMetric
                                                                   views:views]];
    
    [self.noteView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintsV
                                                                 options:0
                                                                 metrics:noteMetric
                                                                   views:views]];
    
    [self.noteView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:toggleViewConstraintV
                                                                 options:0
                                                                 metrics:noteMetric
                                                                   views:views]];
    
    
    [self.noteView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:placeholderConstraintV
                                                                 options:0
                                                                 metrics:noteMetric
                                                                   views:views]];
    [self.noteView addConstraints:constraints];
}

-(void) toggleTapped:(UITapGestureRecognizer *) gr
{
    
    if (self.isTextShowing)
    {
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.noteView removeConstraint:self.placeholderHeightConstraintOpen];
                             [self.noteView addConstraint:self.placeholderHeightConstraintClose];
                             [self.noteView layoutIfNeeded];
                         }completion:^(BOOL completed){
                             [self.placeHolderTextview resignFirstResponder];
                             self.placeHolderTextview.hidden = YES;
                             self.isTextShowing = NO;
                             [self.noteView layoutIfNeeded];
                         }];
    }
    else
    {
        
        self.placeholderHeightConstraintOpen.constant = 0;
        self.placeHolderTextview.hidden = NO;
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             [self.noteView removeConstraint:self.placeholderHeightConstraintClose];
                             [self.noteView addConstraint:self.placeholderHeightConstraintOpen];
                             [self.noteView layoutIfNeeded];
                         }completion:^(BOOL completed){
                             self.isTextShowing = YES;
                             [self.noteView layoutIfNeeded];
                         }];
    }
}

//-(void) togglePanned:(UIPanGestureRecognizer *) sender
//{
//    
//    if(sender.state == UIGestureRecognizerStateChanged ||
//       sender.state == UIGestureRecognizerStateEnded){
//        
//        CGPoint translation = [sender translationInView:self.noteView];
//        
//        if (self.isTextShowing)
//        {
//            if(self.placeholderView.frame.size.height == 0 || self.placeholderView.frame.size.height - translation.y <= 0)
//            {
//                self.isTextShowing = NO;
//                [self.noteView removeConstraint:self.placeholderHeightConstraintOpen];
//                [self.noteView addConstraint:self.placeholderHeightConstraintClose];
//                [self layoutIfNeeded];
//            }
//            else
//            {
//                self.placeholderHeightConstraintOpen.constant -= translation.y;
//                [self layoutIfNeeded];
//            }
//        }
//        else
//        {
//            if (self.placeholderView.frame.size.height - translation.y > 0)
//            {
//                [self.noteView removeConstraint:self.placeholderHeightConstraintClose];
//                [self.noteView addConstraint:self.placeholderHeightConstraintOpen];
//                [self layoutIfNeeded];
//                self.isTextShowing = YES;
//            }
//        }
//        
//        [sender setTranslation:CGPointZero inView:self.noteView];
//    }
//    
//    if (sender.state == UIGestureRecognizerStateEnded)
//    {
//        
//    }
//}

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
    //[super setText:text];
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
                                          self.noteView.bounds.size.width,
                                          self.noteView.bounds.size.height);
    }
}

-(instancetype) prototype
{
    ImageNoteView * prototype = [[ImageNoteView alloc] initWithFrame:self.frame];
    prototype = [super _configurePrototype:prototype];
    UIImageView * newImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    [prototype.noteView addSubview:newImageView];
    prototype.imageView = newImageView;
    newImageView.backgroundColor = self.imageView.backgroundColor;
    newImageView.alpha = self.imageView.alpha;
    [prototype configureImageView];
    return prototype;
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
-(void) resignSubViewsAsFirstResponder
{
    [super resignSubViewsAsFirstResponder];
    [self.placeHolderTextview resignFirstResponder];
}

@end
