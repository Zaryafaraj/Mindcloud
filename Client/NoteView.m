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
    CGRect bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    CGPathRef shadowPath = CGPathCreateWithRect(bounds,&CGAffineTransformIdentity);
    self.layer.shadowPath = shadowPath;
    if (self._textView)
    {
        CGRect newFrame = CGRectMake(TEXT_X_OFFSET,
                                     TEXT_Y_OFFSET,
                                     frame.size.width - 2 * TEXT_X_OFFSET,
                                     frame.size.height - 2 * TEXT_Y_OFFSET);
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
}

-(BOOL) isScalingValid: (CGFloat) scaleFactor;
{
    if (self.scaleOffset * scaleFactor > 2 || self.scaleOffset * scaleFactor < 0.9) return NO;
    else return YES;
}

-(void) scaleWithScaleOffset:(CGFloat) scaleOffset animated:(BOOL) animated
{
    self.scaleOffset = scaleOffset;
    
    CGRect newFrame = CGRectMake(self.frame.origin.x,
                                 self.frame.origin.y,
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
                                 self.frame.size.width * scaleFactor,
                                 self.frame.size.height * scaleFactor);
    self.frame = newFrame;
    
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
