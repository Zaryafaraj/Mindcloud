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
#import "CollectionLayoutHelper.h"

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

-(id) init
{
    self = [super init];
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
            self._textView.keyboardAppearance = UIKeyboardAppearanceLight;
            break;
        }
    }
}

-(void) animateLayoutChangeForBounds:(CGRect) bounds
                        withDuration:(CGFloat) duration
                 andAnimationOptions:(UIViewAnimationOptions) options;
{
    NSString * timingFunction = kCAMediaTimingFunctionLinear;
    
    if (options == UIViewAnimationOptionCurveEaseIn)
    {
        timingFunction = kCAMediaTimingFunctionEaseIn;
    }
    else if (options == UIViewAnimationOptionCurveEaseOut)
    {
        timingFunction = kCAMediaTimingFunctionEaseOut;
    }
    else if (options == UIViewAnimationOptionCurveEaseInOut)
    {
        timingFunction = kCAMediaTimingFunctionEaseInEaseOut;
    }
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunction];
    CGPathRef toValue = CGPathCreateWithRect(bounds,&CGAffineTransformIdentity);
    animation.fromValue = [UIBezierPath bezierPathWithCGPath:toValue];
    animation.toValue = [UIBezierPath bezierPathWithCGPath:self.layer.shadowPath];
    
    self.layer.shadowPath = toValue;
    
    [self.layer addAnimation:animation forKey:@"shadowPath"];
    CGPathRelease(toValue);
}

+(NoteView *) setLayers:(NoteView *) view
{
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderColor = [UIColor clearColor].CGColor;
    view.layer.borderWidth = 1;
    //view.layer.shouldRasterize = YES;
    view.layer.edgeAntialiasingMask = kCALayerTopEdge | kCALayerBottomEdge | kCALayerRightEdge | kCALayerLeftEdge;
    view.clipsToBounds = NO;
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.3;
    view.layer.shadowRadius = 2;
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

-(CGRect) frame
{
    return [super frame];
}

-(void) setFrame:(CGRect)frame
{
    if (!CGAffineTransformIsIdentity(self.transform))
    {
        self.transform = CGAffineTransformIdentity;
    }
    
    [super setFrame:frame];
    
    [self adjustSubViewsForPropertyChangeInNote];
}

-(void) adjustSubViewsForPropertyChangeInNote
{
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
    
    CGPathRelease(shadowPath);
}

-(void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self adjustSubViewsForPropertyChangeInNote];
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
    
    self.transform = CGAffineTransformIdentity;
    
    self.bounds = CGRectMake(0,
                             0, NOTE_WIDTH,
                             NOTE_HEIGHT);
    
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
    
    self.bounds = CGRectMake(self.bounds.origin.x,
                             self.bounds.origin.y,
                             self.originalFrame.size.width * scaleOffset,
                             self.originalFrame.size.height * scaleOffset);
    
}

-(void) scale:(CGFloat) scaleFactor animated:(BOOL)animated{
    
    BOOL isValid = [self isScalingValid:scaleFactor];
    if (!isValid) return;
    
    self.scaleOffset *= scaleFactor;
    
    self.bounds = CGRectMake(self.bounds.origin.x,
                             self.bounds.origin.y,
                             self.bounds.size.width * scaleFactor,
                             self.bounds.size.height * scaleFactor);
}

-(void) rotate:(CGFloat)rotation
{
    self.rotationOffset += rotation;
    self.transform = CGAffineTransformRotate(self.transform, rotation);
}

-(void) enablePaintMode
{
    self._textView.userInteractionEnabled = NO;
}

-(void) disablePaintMode
{
    self._textView.userInteractionEnabled = YES;
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
