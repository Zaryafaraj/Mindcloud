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
#import "NoteAnimator.h"

@interface NoteView()

@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGRect lastFrame;

@end

@implementation NoteView


#define STARTING_POS_OFFSET_X 0.10
#define STARTING_POS_OFFSET_Y 0.15
#define PLACEHOLDER_TEXT @"\n\n\nTap To Edit"
#pragma mark - Synthesizers

@synthesize text = _text;
@synthesize highlighted = _highlighted;
@synthesize ID = _ID;
@synthesize scaleOffset = _scaleOffset;
@synthesize rotationOffset = _rotationOffset;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _configureView];
    }
    return self;
}

-(instancetype) _configureView
{
    [NoteView setLayers:self];
    [self configureTextView];
    return self;
}

-(void) configureTextView
{
    //find the text view
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UITextView class]])
        {
            self._textView = ((UITextView *) subView);
            self._textView.delegate = self;
            self._textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
            self._textView.textAlignment = NSTextAlignmentCenter;
            self._textView.text = PLACEHOLDER_TEXT;
            UIColor * themeColor = [[ThemeFactory currentTheme] tintColor];
            self._textView.textColor = [UIColor colorWithWhite:0.25 alpha:1];
            self._textView.tintColor = themeColor;
            self._textView.keyboardAppearance = UIKeyboardAppearanceDark;
            break;
        }
    }
}

+(NoteView *) setLayers:(NoteView *) view
{
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1;
//    view.layer.shouldRasterize = YES;
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(1, 2);
    view.layer.shadowOpacity = 0.9;
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

-(CGFloat) rotationOffset
{
    return _rotationOffset;
}

-(void) setDelegate:(id<NoteViewDelegate>) delegate{
    _delegate = delegate;
}

-(void) setHighlighted:(BOOL) highlighted
{
    _highlighted = highlighted;
    if (highlighted)
    {
        [NoteAnimator animateNoteHighlighted:self];
    }
    else
    {
        [NoteAnimator animateNoteUnhighlighted:self];
    }
}

-(void) setFrame:(CGRect)frame
{
    //NSLog(@"\n\n NEW FRAME \n %f - %f -- %f - %f ", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    //NSLog(@"\n\n OLDFRAME \n %f - %f -- %f - %f ", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    [super setFrame:frame];
    //NSLog(@"\n\n AFTER FRAME \n %f - %f -- %f - %f ", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    CGRect bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    CGPathRef shadowPath = CGPathCreateWithRect(bounds,&CGAffineTransformIdentity);
    self.layer.shadowPath = shadowPath;
    if (self._textView)
    {
        CGRect newFrame = CGRectMake(TEXT_X_OFFSET,
                                     TEXT_Y_OFFSET,
                                     self.bounds.size.width - 2 * TEXT_X_OFFSET,
                                     self.bounds.size.height - 2 * TEXT_Y_OFFSET);
        self._textView.frame = newFrame;
    }
}

-(void) setText:(NSString *) text
{
    self._textView.text = text;
}

-(NSString *) text
{
    if (self._textView != nil)
    {
        return self._textView.text;
    }
    
    return nil;
}

#pragma mark - layout

-(void) resetSize{
    
    [self setFrame: self.originalFrame];
    
    self.scaleOffset = 1;
    self.rotationOffset = 0;
}

-(BOOL) isScalingValid: (CGFloat) scaleFactor;
{
    if (self.scaleOffset * scaleFactor > 2 || self.scaleOffset * scaleFactor < 0.9) return NO;
    else return YES;
}

-(void) scaleWithScaleOffset:(CGFloat) scaleOffset animated:(BOOL) animated
{
    self.scaleOffset = scaleOffset;
    
    CGRect newFrame = CGRectMake(self.bounds.origin.x,
                                 self.bounds.origin.y,
                                 self.originalFrame.size.width * scaleOffset,
                                 self.originalFrame.size.height * scaleOffset);
    
    self.frame = newFrame;
    
}

-(void) scale:(CGFloat) scaleFactor animated:(BOOL)animated{
    
    BOOL isValid = [self isScalingValid:scaleFactor];
    if (!isValid) return;
    
    self.scaleOffset *= scaleFactor;
    
    CGRect newFrame = CGRectMake(self.frame.origin.x,
                                 self.frame.origin.y,
                                 self.bounds.size.width * scaleFactor,
                                 self.bounds.size.height * scaleFactor);
    self.frame = newFrame;
    
}

-(void) rotate:(CGFloat)rotation
{
    self.rotationOffset += rotation;
    self.transform = CGAffineTransformRotate(self.transform, rotation);
    NSLog(@"\n\n============== ROTATE =============\n\n");
}

-(void) resizeToRect:(CGRect) rect
{
    self.frame = rect;
}

-(void) resizeToRect:(CGRect)rect
             Animate: (BOOL) animate{
    
    if (animate){
        [UIView animateWithDuration:0.5 animations:^{
            [self resizeToRect:rect];
        }];
    }
    else {
        [self resizeToRect:rect];
    }
}

-(instancetype) prototype
{
    NoteView * prototype = [[NoteView alloc] initWithFrame:self.frame];
    
    if (prototype == nil) return nil;
    
    prototype = [self _configurePrototype:prototype];
    return prototype;
}

-(instancetype) _configurePrototype: (NoteView *) prototype
{
    UITextView * prototypeTextView = [[UITextView alloc] initWithFrame:self._textView.frame];
    prototypeTextView.backgroundColor = self._textView.backgroundColor;
    [prototype addSubview:prototypeTextView];
    prototype._textView = prototypeTextView;
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
    if ([textView.text isEqualToString:PLACEHOLDER_TEXT]){
        textView.text = @"";
    }
    self.delegate.activeView = self;
}



@end
