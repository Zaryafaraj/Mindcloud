//
//  NoteView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "NoteView.h"
#import "CollectionAnimationHelper.h"
#import "ThemeFactory.h"

@interface NoteView()

@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGRect lastFrame;
@property (weak, nonatomic) UITextView * textView;

@end

@implementation NoteView

#define TEXT_X_OFFSET 20
#define TEXT_Y_OFFSET 20

#define STARTING_POS_OFFSET_X 0.10
#define STARTING_POS_OFFSET_Y 0.15
#define TEXT_WIDHT_RATIO 0.8
#define TEXT_HEIGHT_RATIO 0.75

#pragma mark - Synthesizers

@synthesize text = _text;
@synthesize highlighted = _highlighted;
@synthesize ID = _ID;
@synthesize scaleOffset = _scaleOffset;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self = [NoteView setLayers:self];
        [self configureTextView];
    }
    return self;
}

-(void) configureTextView
{
    //find the text view
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UITextView class]])
        {
            self.textView = ((UITextView *) subView);
            self.textView.delegate = self;
            self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            self.textView.textAlignment = NSTextAlignmentCenter;
            self.textView.text = @"\n\n\nTap To Edit";
            UIColor * themeColor = [[ThemeFactory currentTheme] tintColor];
            self.textView.tintColor = themeColor;
            self.textView.keyboardAppearance = UIKeyboardAppearanceDark;
            break;
        }
    }
    
}
+(NoteView *) setLayers:(NoteView *) view
{
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.shouldRasterize = YES;
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(1, 4);
    view.layer.shadowOpacity = 0.7;
    return view;
}

-(CGFloat)scaleOffset
{
    if (_scaleOffset <= 0)
    {
        _scaleOffset = 1;
    }
    return _scaleOffset;
}

-(void) setDelegate:(id<NoteViewDelegate>) delegate{
    _delegate = delegate;
}

-(void) setHighlighted:(BOOL) highlighted{
    _highlighted = highlighted;
    
    //we make sure that we highlight textbox/or image in the note
    for (UIView * subView in self.subviews){
        
        if (highlighted){
            if ([subView isKindOfClass:[UIImageView class]]){
                [UIView animateWithDuration:0.20
                                 animations:^{
                                     [subView setTransform:CGAffineTransformMakeScale(1.2, 1.3)];}];
            }
        }
        else{
            if ([subView isKindOfClass:[UIImageView class]]){
                [UIView animateWithDuration:0.20 animations:^{[subView setTransform:CGAffineTransformIdentity];}];
                
            }
        }
    }
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self.textView)
    {
        CGRect newFrame = CGRectMake(TEXT_X_OFFSET,
                                     TEXT_Y_OFFSET,
                                     frame.size.width - 2 * TEXT_X_OFFSET,
                                     frame.size.height - 2 * TEXT_Y_OFFSET);
        self.textView.frame = newFrame;
    }
}
-(void) setText:(NSString *) text
{
    self.textView.text = text;
}

-(NSString *) text
{
    if (self.textView != nil)
    {
        return self.textView.text;
    }
    
    return nil;
}

#pragma mark - layout

-(void) resetSize{
    
    [self setFrame: self.originalFrame];
    
    self.scaleOffset = 1;
}

-(BOOL) isScalingValid: (CGFloat) scaleFactor;
{
    if (self.scaleOffset * scaleFactor > 2 || self.scaleOffset * scaleFactor < 0.9) return NO;
    else return YES;
}

-(void) scaleWithScaleOffset:(CGFloat) scaleOffset animated:(BOOL) animated
{
//    self.scaleOffset = scaleOffset;
//    
//    CGRect newFrame = CGRectMake(self.frame.origin.x,
//                                 self.frame.origin.y,
//                                 self.originalFrame.size.width * scaleOffset,
//                                 self.originalFrame.size.height * scaleOffset);
//    
//    self.frame = newFrame;
//    
//    for (UIView * subView in self.subviews){
//        
//        if ([subView isKindOfClass:[UIImageView class]]){
//            CGRect newFrame2 = CGRectMake(self.bounds.origin.x,
//                                          self.bounds.origin.y,
//                                          self.bounds.size.width,
//                                          self.bounds.size.height);
//            
//            if (animated)
//            {
//                [CollectionAnimationHelper animateChangeFrame:subView withNewFrame:newFrame2];
//            }
//            else
//            {
//                subView.frame = newFrame2;
//            }
//        }
//        else if ([subView isKindOfClass:[UITextView class]]){
//            //doing this to make the text clearer instead of resizing an existing UITextView
//            
//            CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
//                                          self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
//                                          self.bounds.size.width * TEXT_WIDHT_RATIO,
//                                          self.bounds.size.height * TEXT_HEIGHT_RATIO);
//            
//            [CollectionAnimationHelper animateChangeFrame:subView
//                                             withNewFrame:textFrame];
//        }
//    }
}

-(void) scale:(CGFloat) scaleFactor animated:(BOOL)animated{
    
//    BOOL isValid = [self isScalingValid:scaleFactor];
//    if (!isValid) return;
//    
//    self.scaleOffset *= scaleFactor;
//    
//    CGRect newFrame = CGRectMake(self.frame.origin.x,
//                                 self.frame.origin.y,
//                                 self.frame.size.width * scaleFactor,
//                                 self.frame.size.height * scaleFactor);
//    self.frame = newFrame;
//    
//    for (UIView * subView in self.subviews){
//        
//        if ([subView isKindOfClass:[UIImageView class]]){
//            CGRect newFrame2 = CGRectMake(subView.frame.origin.x,
//                                          subView.frame.origin.y,
//                                          subView.frame.size.width * scaleFactor,
//                                          subView.frame.size.height * scaleFactor);
//            
//            if (animated)
//            {
//                [CollectionAnimationHelper animateChangeFrame:subView withNewFrame:newFrame2];
//            }
//            else
//            {
//                subView.frame = newFrame2;
//            }
//        }
//        else if ([subView isKindOfClass:[UITextView class]]){
//            //doing this to make the text clearer instead of resizing an existing UITextView
//            NSString * oldText = ((UITextView *)subView).text;
//            CGRect textFrame = CGRectMake(newFrame.size.width * STARTING_POS_OFFSET_X ,
//                                          newFrame.size.height * STARTING_POS_OFFSET_Y,
//                                          subView.frame.size.width * scaleFactor,
//                                          subView.frame.size.height * scaleFactor);
//            
//            UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
//            textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
//            
//            [textView setBackgroundColor:[UIColor clearColor]];
//            
//            textView.textColor = ((UITextView *)subView).textColor;
//            textView.text = oldText;
//            
//            textView.delegate = self;
//            [subView removeFromSuperview];
//            
//            [self addSubview:textView];
//        }
//    }
}

-(void) resizeToRect:(CGRect) rect
{
//    self.frame = rect;
//    for (UIView * subView in self.subviews){
//        if ([subView isKindOfClass:[UIImageView class]]){
//            subView.frame = CGRectMake(self.bounds.origin.x,
//                                       self.bounds.origin.y,
//                                       self.bounds.size.width,
//                                       self.bounds.size.height);
//        }
//        else if ([subView isKindOfClass:[UITextView class]]){
//            //doing this to make the text clearer instead of resizing an existing UITextView
//            NSString * oldText = ((UITextView *)subView).text;
//            CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
//                                          self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
//                                          self.bounds.size.width * TEXT_WIDHT_RATIO,
//                                          self.bounds.size.height * TEXT_HEIGHT_RATIO);
//            UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
//            textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
//            textView.textColor = ((UITextView *)subView).textColor;
//            [textView setBackgroundColor:[UIColor clearColor]];
//            
//            textView.text = oldText;
//            textView.delegate = self;
//            
//            [subView removeFromSuperview];
//            
//            [self addSubview:textView];
//        }
//    }
}

-(void) resizeToRect:(CGRect)rect
             Animate: (BOOL) animate{
    
//    if (animate){
//        [UIView animateWithDuration:0.5 animations:^{
//            [self resizeToRect:rect];
//        }];
//    }
//    else {
//        [self resizeToRect:rect];
//    }
}

-(instancetype) prototype
{
    NoteView * prototype = [[NoteView alloc] initWithFrame:self.frame];
    
    if (prototype == nil) return nil;
    
    UITextView * prototypeTextView = [[UITextView alloc] initWithFrame:self.textView.frame];
    prototypeTextView.backgroundColor = self.textView.backgroundColor;
    [prototype addSubview:prototypeTextView];
    prototype.textView = prototypeTextView;
    prototype.text = self.text;
    prototype.delegate = self.delegate;
    prototype.backgroundColor = self.backgroundColor;
    prototype.alpha = self.alpha;
    prototype = [NoteView setLayers:prototype];
    [prototype configureTextView];
    
    return prototype;
}

#pragma mark - keyboard
-(void) resignSubViewsAsFirstResponder{
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UITextView class]]){
            if (subView.isFirstResponder){
                [subView resignFirstResponder];
            }
        }
    }
}

#pragma  - text view
-(void) textViewDidEndEditing:(UITextView *)textView{
    NSString * text = textView.text;
    [self.delegate note:self changedTextTo:text];
    self.delegate.activeView = nil;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"Tap To Edit Note"]){
        textView.text = @"";
    }
    self.delegate.activeView = self;
}


@end
