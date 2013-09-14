//
//  NoteView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "NoteView.h"
#import "CollectionAnimationHelper.h"

@interface NoteView()

@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGRect lastFrame;

@end

@implementation NoteView

#define STARTING_POS_OFFSET_X 0.10
#define STARTING_POS_OFFSET_Y 0.15
#define TEXT_WIDHT_RATIO 0.8
#define TEXT_HEIGHT_RATIO 0.75

#pragma mark - Synthesizers

@synthesize text = _text;
@synthesize highlighted = _highlighted;
@synthesize highLightedImage = _highLightedImage;
@synthesize normalImage = _normalImage;
@synthesize ID = _ID;
@synthesize scaleOffset = _scaleOffset;

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

-(UIImage *) normalImage{
    if (!_normalImage){
        _normalImage = [UIImage imageNamed:@"notelight5.png"];
    }
    return _normalImage;
}


-(UIImage *) highLightedImage{
    
    if (! _highLightedImage){
        _highLightedImage = [UIImage imageNamed:@"noteselected.png"];
        
    }
    return _highLightedImage;
}

-(void) setHighlighted:(BOOL) highlighted{
    _highlighted = highlighted;
    
    //we make sure that we highlight textbox/or image in the note
    for (UIView * subView in self.subviews){
        
        if (highlighted){
            if ([subView isKindOfClass:[UIImageView class]]){
                [((UIImageView *) subView) setImage:self.highLightedImage];
                [UIView animateWithDuration:0.20
                                 animations:^{
                                     [subView setTransform:CGAffineTransformMakeScale(1.2, 1.3)];}];
            }
        }
        else{
            if ([subView isKindOfClass:[UIImageView class]]){
                [((UIImageView *) subView) setImage:self.normalImage];
                [UIView animateWithDuration:0.20 animations:^{[subView setTransform:CGAffineTransformIdentity];}];
                
            }
        }
    }
}

-(void) setText:(NSString *) text{
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UITextView class]]){
            ((UITextView *) subView).text = text;
            return;
        }
    }
}

-(NSString *) text{
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UITextView class]]){
            return ((UITextView *) subView).text;
        }
    }
    return nil;
}

#pragma mark - initializer
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //save the original frame so when we change back from highlighted we can return to it
        self.originalFrame = CGRectMake(frame.origin.x,
                                        frame.origin.y,
                                        frame.size.width,
                                        frame.size.height);
        
        UIImageView * imageView = [[UIImageView alloc] initWithImage:self.normalImage];
        imageView.frame = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     self.bounds.size.width,
                                     self.bounds.size.height);
       
        CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                      self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                      self.bounds.size.width * TEXT_WIDHT_RATIO,
                                      self.bounds.size.height * TEXT_HEIGHT_RATIO);
        UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
        textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
        [textView setBackgroundColor:[UIColor clearColor]];
        
        textView.delegate = self;
        [self addSubview:imageView];
        [self addSubview:textView];
        self.text = @"Tap To Edit Note";
    }
    return self;
}

-(id) initNoteWithFrame:(CGRect) frame 
                andText: (NSString *)text
                  andID:(NSString *)ID{
    
    self = [self initWithFrame:frame];
    self.text = text;
    self.ID = ID;
    return self;
}

#pragma mark - layout

-(void) resetSize{
    
    [self setFrame: self.originalFrame];
    
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UIImageView class]]){
            subView.frame = CGRectMake(self.bounds.origin.x,
                                       self.bounds.origin.y,
                                       self.bounds.size.width,
                                       self.bounds.size.height);
        }
        else if ([subView isKindOfClass:[UITextView class]]){
            subView.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                       self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                       self.bounds.size.width * TEXT_WIDHT_RATIO, self.bounds.size.height * TEXT_HEIGHT_RATIO);
        }
    }
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
    
    for (UIView * subView in self.subviews){
        
        if ([subView isKindOfClass:[UIImageView class]]){
            CGRect newFrame2 = CGRectMake(self.bounds.origin.x,
                                          self.bounds.origin.y,
                                          self.bounds.size.width,
                                          self.bounds.size.height);
            
            if (animated)
            {
                [CollectionAnimationHelper animateChangeFrame:subView withNewFrame:newFrame2];
            }
            else
            {
                subView.frame = newFrame2;
            }
        }
        else if ([subView isKindOfClass:[UITextView class]]){
            //doing this to make the text clearer instead of resizing an existing UITextView
            
        CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                      self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                      self.bounds.size.width * TEXT_WIDHT_RATIO,
                                      self.bounds.size.height * TEXT_HEIGHT_RATIO);
            
            [CollectionAnimationHelper animateChangeFrame:subView
                                             withNewFrame:textFrame];
        }
    }
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
    
    for (UIView * subView in self.subviews){
        
        if ([subView isKindOfClass:[UIImageView class]]){
            CGRect newFrame2 = CGRectMake(subView.frame.origin.x,
                                       subView.frame.origin.y,
                                       subView.frame.size.width * scaleFactor,
                                       subView.frame.size.height * scaleFactor);
            
            if (animated)
            {
                [CollectionAnimationHelper animateChangeFrame:subView withNewFrame:newFrame2];
            }
            else
            {
                subView.frame = newFrame2;
            }
        }
        else if ([subView isKindOfClass:[UITextView class]]){
            //doing this to make the text clearer instead of resizing an existing UITextView
            NSString * oldText = ((UITextView *)subView).text;
            CGRect textFrame = CGRectMake(newFrame.size.width * STARTING_POS_OFFSET_X ,
                                          newFrame.size.height * STARTING_POS_OFFSET_Y,
                                          subView.frame.size.width * scaleFactor,
                                          subView.frame.size.height * scaleFactor);
            
            UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
            textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
            
            [textView setBackgroundColor:[UIColor clearColor]];
            
            textView.textColor = ((UITextView *)subView).textColor;
            textView.text = oldText;
            
            textView.delegate = self;
            [subView removeFromSuperview];
            
            [self addSubview:textView];
        }
    }
}

-(void) resizeToRect:(CGRect) rect
{
    self.frame = rect;
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UIImageView class]]){
            subView.frame = CGRectMake(self.bounds.origin.x,
                                       self.bounds.origin.y,
                                       self.bounds.size.width,
                                       self.bounds.size.height);
        }
        else if ([subView isKindOfClass:[UITextView class]]){
            //doing this to make the text clearer instead of resizing an existing UITextView
            NSString * oldText = ((UITextView *)subView).text;
            CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                          self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                          self.bounds.size.width * TEXT_WIDHT_RATIO,
                                          self.bounds.size.height * TEXT_HEIGHT_RATIO);
            UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
            textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
            textView.textColor = ((UITextView *)subView).textColor;
            [textView setBackgroundColor:[UIColor clearColor]];
            
            textView.text = oldText;
            textView.delegate = self;
            
            [subView removeFromSuperview];
            
            [self addSubview:textView];
        }
    }
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
