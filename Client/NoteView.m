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

@property (nonatomic) CGRect lastFrame;
@property (nonatomic) UIButton * deleteButton;
@property (nonatomic) UIButton * unstackButton;
@property (nonatomic) UIView * noteView;
@end

@implementation NoteView


#define STARTING_POS_OFFSET_X 0.10
#define STARTING_POS_OFFSET_Y 0.15
#pragma mark - Synthesizers

@synthesize text = _text;
@synthesize highlighted = _highlighted;
@synthesize ID = _ID;
@synthesize scaleOffset = _scaleOffset;
@synthesize rotationOffset = _rotationOffset;
@synthesize selectedInStack = _selectedInStack;

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
        _deleteButton.frame = CGRectMake(0,0 , 40, 40);
        _deleteButton.tintColor = [[ThemeFactory currentTheme] tintColorForDeleteIcon];
    }
    return _deleteButton;
}

-(UIButton *) unstackButton
{
    if(!_unstackButton)
    {
        UIButton * unstackBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _unstackButton = unstackBtn;
        [_unstackButton addTarget:self
                           action:@selector(unstackPressed:)
                 forControlEvents:UIControlEventTouchDown];
        
        UIImage * btnImage = [[ThemeFactory currentTheme] imageForUnstack];
        [_unstackButton setImage:btnImage
                        forState:UIControlStateNormal];
        [self addSubview:_unstackButton];
        _unstackButton.frame = CGRectMake(0,0 , 40, 40);
        _unstackButton.tintColor = [[ThemeFactory currentTheme] tintColorForIconsInStack];
        _unstackButton.hidden = YES;
    }
    return _unstackButton;
}
-(instancetype) _configureView
{
    //self.backgroundColor = [UIColor blueColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.noteView = self.subviews.firstObject;
    [NoteView setLayers:self];
    [self configureTextView];
    return self;
}

-(void) configureTextView
{
    //find the text view
    for (UIView * subView in self.noteView.subviews){
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
    animation.fromValue = [UIBezierPath bezierPathWithCGPath:self.noteView.layer.shadowPath];
    animation.toValue = [UIBezierPath bezierPathWithCGPath:toValue];
    
    self.noteView.layer.shadowPath = toValue;
    
    [self.noteView.layer addAnimation:animation forKey:@"shadowPath"];
    CGPathRelease(toValue);
}

#define DEFAULT_SHADOW_OPACITY 0.3
#define DEFAULT_SHADOW_SIZE CGSizeMake(0,1)
#define DEFAULT_SHADOW_RADIUS 2
+(NoteView *) setLayers:(NoteView *) noteView
{
    UIView * view = noteView.noteView;
    view.backgroundColor = [UIColor whiteColor];
    //view.layer.shouldRasterize = YES;
    view.layer.edgeAntialiasingMask = kCALayerTopEdge | kCALayerBottomEdge | kCALayerRightEdge | kCALayerLeftEdge;
    view.clipsToBounds = NO;
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = DEFAULT_SHADOW_SIZE;
    view.layer.shadowOpacity = DEFAULT_SHADOW_OPACITY;
    view.layer.shadowRadius = DEFAULT_SHADOW_RADIUS;
    
    return noteView;
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

-(void) setCenter:(CGPoint)center
{
    [super setCenter:center];
}
-(void) setSelectedInStack:(BOOL)selectedInStack
{
    if (selectedInStack == _selectedInStack)
    {
        return;
    }
    
    if (selectedInStack)
    {
        
        self.deleteButton.tintColor = [[ThemeFactory currentTheme] tintColorForIconsInStack];
        [NoteAnimator animateNoteSelectedInStack:self
                                withDeleteButton:self.deleteButton
                                andUnstackButton:self.unstackButton];
    }
    else
    {
        [NoteAnimator animateNoteDeselectedInStack:self
                                  withDeleteButton:self.deleteButton
                                  andUnstackButton:self.unstackButton];
    }
    _selectedInStack = selectedInStack;
}

-(void) setHighlighted:(BOOL) highlighted
{
    _highlighted = highlighted;
    
    if (highlighted)
    {
        self.deleteButton.tintColor = [[ThemeFactory currentTheme] tintColorForDeleteIcon];
        [NoteAnimator animateNoteHighlighted:self withDeleteButton:self.deleteButton];
    }
    else
    {
        [NoteAnimator animateNoteUnhighlighted:self withDeleteButton:self.deleteButton];
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
    CGRect noteFrame = CGRectMake(20,
                                  20,
                                  self.bounds.size.width - 40,
                                  self.bounds.size.height - 40);
    
    CGRect shadowFrame = CGRectMake(0, 0, noteFrame.size.width, noteFrame.size.height);
    self.noteView.frame = noteFrame;
    CGPathRef shadowPath = CGPathCreateWithRect(shadowFrame,&CGAffineTransformIdentity);
    self.noteView.layer.shadowPath = shadowPath;
    
    if (self._textView)
    {
        CGRect newFrame = CGRectMake(TEXT_X_OFFSET,
                                     TEXT_Y_OFFSET,
                                     self.noteView.bounds.size.width - 2 * TEXT_X_OFFSET,
                                     self.noteView.bounds.size.height - 2 * TEXT_Y_OFFSET);
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
    self.noteView.layer.shadowOffset = DEFAULT_SHADOW_SIZE;
    self.noteView.layer.shadowOpacity = DEFAULT_SHADOW_OPACITY;
    self.noteView.layer.shadowRadius = DEFAULT_SHADOW_RADIUS;
    [self adjustSubViewsForPropertyChangeInNote];
}

-(BOOL) isScalingValid: (CGFloat) scaleFactor;
{
    if (self.scaleOffset * scaleFactor > 2 || self.scaleOffset * scaleFactor < 0.9)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void) scaleWithScaleOffset:(CGFloat) scaleOffset animated:(BOOL) animated
{
    self.scaleOffset = scaleOffset;
    
    self.bounds = CGRectMake(self.bounds.origin.x,
                             self.bounds.origin.y,
                             NOTE_WIDTH * scaleOffset,
                             NOTE_HEIGHT * scaleOffset);
    
}

-(void) scaleWithScaleOffset:(CGFloat) scaleOffset
            fromOriginalSize:(CGSize) size
                    animated:(BOOL) animated
{
    self.scaleOffset = scaleOffset;
    
    self.bounds = CGRectMake(self.bounds.origin.x,
                             self.bounds.origin.y,
                             size.width * scaleOffset,
                             size.height * scaleOffset);
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
    //self._textView.userInteractionEnabled = NO;
}

-(void) disablePaintMode
{
    //self._textView.userInteractionEnabled = YES;
}

-(void) unstackPressed:(id)sender
{
    id<NoteViewDelegate> temp = self.delegate;
    if (temp)
    {
        [temp unstackPressed:self];
    }
}

-(void) deletePressed:(id)sender
{
    id<NoteViewDelegate> temp = self.delegate;
    if (temp)
    {
        [temp deletePressed:self];
    }
    
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
    UIView * protoTypeNoteView = [[UIView alloc] initWithFrame:self.noteView.frame];
    prototypeTextView.backgroundColor = self._textView.backgroundColor;
    [protoTypeNoteView addSubview:prototypeTextView];
    prototype._textView = prototypeTextView;
    prototype.text = self.text;
    [prototype addSubview:protoTypeNoteView];
    prototype.delegate = self.delegate;
    prototype.noteView = protoTypeNoteView;
    prototype.backgroundColor = self.backgroundColor;
    prototype.alpha = self.alpha;
    prototype = [NoteView setLayers:prototype];
    [prototype configureTextView];
    return prototype;
}

#pragma mark - keyboard
-(void) resignSubViewsAsFirstResponder{
    for (UIView * subView in self.noteView.subviews){
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
    NSString * smallerPlaceholder = [PLACEHOLDER_TEXT stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if ([textView.text isEqualToString:PLACEHOLDER_TEXT] ||
        [textView.text isEqualToString:smallerPlaceholder]){
        textView.text = @"";
    }
    
    //in case we are in a modal view and becoming first resoponder is deactivated
    [textView becomeFirstResponder];
    self.delegate.activeView = self;
}


-(UIView *) getEnclosingNoteView
{
    return self.noteView;
}

@end
