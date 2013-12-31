//
//  StackView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 5/16/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "StackView.h"
#import "ImageNoteView.h"
#import "CollectionAnimationHelper.h"
#import "CollectionLayoutHelper.h"

#define MAX_VISIBLE_NOTES 3
#define STACKING_DURATION 0.3

@interface StackView()

@property CGRect originalFrame;
@property NSMutableArray * tempTopItems;

@end

@implementation StackView

@synthesize text = _text;
@synthesize highlighted = _highlighted;
@synthesize ID = _ID;
@synthesize scaleOffset = _scaleOffset;
@synthesize rotationOffset = _rotationOffset;

-(CGFloat)scaleOffset
{
    if (_scaleOffset <= 0)
    {
        _scaleOffset = 1;
    }
    return _scaleOffset;
}


/*! the last three items on the views are the top of the stack
 */
-(NoteView *) mainView
{
    if (self.views == nil || [self.views count] ==0)
    {
        return nil;
    }
    else
    {
        int lastIndex = [self.views count] -1;
        return self.views[lastIndex];
    }
}

-(void) setHighlighted:(BOOL) highlighted
{
    _highlighted = highlighted;
    [self animateStackHighlighted:highlighted];
}


-(void) rotate:(CGFloat)rotation
{
    //nothing to do in stack view
}

-(void) setCenter:(CGPoint)center
{
    [super setCenter:center];
    
}

//Stack view consists of a bigger transparetn view which includes at most the top 3 notes
-(id) initWithViews: (NSMutableArray *) views
        andMainView: (NoteView *) mainView
          withFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.views = views;
        //determine the topview
        [self setTopViewForMainView:mainView];
        self.originalFrame = self.frame;
        [self layoutStackView];
    }
    //self.backgroundColor = [UIColor darkGrayColor];
    return self;
}

-(CGFloat) rotationAngleForStacking
{
    return M_PI_4 * 1/8;
}

-(void) animateStackingOfTopItem:(NoteView *) note
{
    
    CGRect aBound = CGRectMake(0,
                               0,
                               self.bounds.size.width,
                               self.bounds.size.height);
    
    UIViewAnimationOptions option = UIViewAnimationOptionCurveEaseIn;
    [note animateLayoutChangeForBounds:aBound
                          withDuration:STACKING_DURATION andAnimationOptions:option];
    
    [UIView animateWithDuration:STACKING_DURATION delay:0
                        options:option
                     animations:^{
                         
                         
                         
                         note.bounds = CGRectMake(0,
                                                  0,
                                                  self.bounds.size.width - 2 * NOTE_OFFSET_FROM_STACKING,
                                                  self.bounds.size.height - 2 * NOTE_OFFSET_FROM_STACKING);
                         note.transform = CGAffineTransformIdentity;
                         note.center = self.center;
                     }completion:^(BOOL finished){
                         
                         [note removeFromSuperview];
                         
                         note.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                         
                         note.bounds = CGRectMake(0,
                                                  0,
                                                  self.bounds.size.width - 2 * NOTE_OFFSET_FROM_STACKING,
                                                  self.bounds.size.height - 2 * NOTE_OFFSET_FROM_STACKING);
                         
                         [self addSubview:note];
                     }
     ];
}


-(void) animateStackingOfBelowItems:(NoteView *) note
                  withRotationAngle:(CGFloat) angle
{
    
    CGRect aBound = CGRectMake(0,
                               0,
                               self.bounds.size.width,
                               self.bounds.size.height);
    
    UIViewAnimationOptions option = UIViewAnimationOptionCurveEaseIn;
    [note animateLayoutChangeForBounds:aBound
                          withDuration:STACKING_DURATION andAnimationOptions:option];
    
    [UIView animateWithDuration:STACKING_DURATION delay:0
                        options:option
                     animations:^{
                         CGFloat rotationRight = angle;
                         CGFloat totalRotation = rotationRight;
                         note.transform = CGAffineTransformRotate(CGAffineTransformIdentity, totalRotation);
                         
                         
                         note.bounds = CGRectMake(0,
                                                  0,
                                                  self.bounds.size.width - 2 * NOTE_OFFSET_FROM_STACKING,
                                                  self.bounds.size.height - 2 * NOTE_OFFSET_FROM_STACKING);
                         note.center = self.center;
                     }completion:^(BOOL finished){
                         
                         [note removeFromSuperview];
                         
                         
                         note.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                         
                         note.bounds = CGRectMake(0,
                                                  0,
                                                  self.bounds.size.width - 2 * NOTE_OFFSET_FROM_STACKING,
                                                  self.bounds.size.height - 2 * NOTE_OFFSET_FROM_STACKING);
                         
                         //if we are laying this on top of something else make sure it actually appears on top
                         int index = [self.views indexOfObject:note];
                         
                         if (index < [self.views count] - 1)
                         {
                             [self insertSubview:note
                                    belowSubview:self.views[index+1]];
                         }
                         else
                         {
                             [self addSubview:note];
                         }
                         
                     }
     ];
}

-(void) animateStackingOfInvisibleItems:(NoteView *) note
{
    
    [UIView animateWithDuration:STACKING_DURATION delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                         note.frame = CGRectMake(self.frame.origin.x,
                                                 self.frame.origin.y,
                                                 self.bounds.size.width,
                                                 self.bounds.size.height);
                     }completion:^(BOOL finished){
                         
                         [note removeFromSuperview];
                         [note resetSize];
                         
                     }
     ];
}

-(void) layoutStackView
{
    
    //self.backgroundColor = [UIColor greenColor];
    //move the top of the note to the stack frame
    for (int i = 0 ; i < [self.views count]; i++)
    {
        NoteView * note = self.views[i];
        
        //first clean the note up
        for(UIGestureRecognizer * gr in note.gestureRecognizers)
        {
            [note removeGestureRecognizer:gr];
        }
        
        if ([note isKindOfClass:[ImageNoteView class]])
        {
            ImageNoteView * imgNoteView = (ImageNoteView *) note;
            imgNoteView.contentMode = UIViewContentModeScaleAspectFill;
            imgNoteView.clipsToBounds = YES;
            imgNoteView.hideControls = YES;
        }
        
        note._textView.editable = NO;
        
        //if its the top of the stack move it on top without rotation
        if (i == [self.views count] - 1)
        {
            [self animateStackingOfTopItem:note];
        }
        
        //rotate the second to top to the right
        else if ( i == [self.views count] - 2)
        {
            
            [self animateStackingOfBelowItems:note withRotationAngle:[self rotationAngleForStacking]];
        }
        
        //rotate the third to top to the left
        else if ( i == [self.views count] - 3)
        {
            [self animateStackingOfBelowItems:note withRotationAngle:-[self rotationAngleForStacking]];
        }
        
        //for the rest no extra operations are needed
        else
        {
            [self animateStackingOfInvisibleItems:note];
        }
    }
}

-(void) stackDidFinishMoving
{
    UIView * refView = [self.views lastObject];
    for (UIView * view in self.views)
    {
        if (view.superview == self && view != refView)
        {
            [UIView animateWithDuration:0.3
                                  delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 view.center = refView.center;
                             }completion: ^(BOOL finished){
                                 
                             }];
            
        }
    }
}

-(void) stackWillClose
{
    for (NoteView * view in self.tempTopItems)
    {
        
        [view removeFromSuperview];
    }
    
    [self.tempTopItems removeAllObjects];
    
    for (int i = 0 ; i < [self.views count]; i++)
    {
        NoteView * note = self.views[i];
        
        //first clean the note up
        for(UIGestureRecognizer * gr in note.gestureRecognizers)
        {
            [note removeGestureRecognizer:gr];
        }
        
        note._textView.editable = NO;
        //if its the top of the stack move it on top without rotation
        [note removeFromSuperview];
        
        note.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        note.bounds = CGRectMake(0,
                                 0,
                                 self.bounds.size.width,
                                 self.bounds.size.height);
        
        if (i == [self.views count] - 1)
        {
            [self addSubview:note];
        }
        
        else if ( i == [self.views count] - 2 || i == [self.views count] - 3)
        {
            
            //if we are laying this on top of something else make sure it actually appears on top
            int index = [self.views indexOfObject:note];
            
            if (index < [self.views count] - 1)
            {
                [self insertSubview:note
                       belowSubview:self.views[index+1]];
            }
            else
            {
                [self addSubview:note];
            }
            
            CGFloat totalRotation = [self rotationAngleForStacking];
            
            if (i == [self.views count] -2 )
            {
                note.transform = CGAffineTransformRotate(note.transform, -totalRotation);
            }
            else
            {
                
                note.transform = CGAffineTransformRotate(note.transform, totalRotation);
            }
        }
        
        //for the rest no extra operations are needed
        else
        {
            [note resetSize];
        }
    }
}

-(void) stackWillOpen
{
    
    NSMutableArray * tempItems = [NSMutableArray arrayWithCapacity:MAX_VISIBLE_NOTES];
    for (int i = 0 ; i < [self.views count]; i++)
    {
        NoteView * note = self.views[i];
        //if its the top of the stack move it on top without rotation
        
        if (i == [self.views count] - 1)
        {
            //remove the original one from superview
            [note removeFromSuperview];
            NoteView * mockNote = [note prototype];
            mockNote.hidden = NO;
            mockNote.text = note.text;
            
            mockNote.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            mockNote.bounds = CGRectMake(0,
                                         0,
                                         self.bounds.size.width,
                                         self.bounds.size.height);
            [self addSubview:mockNote];
            [tempItems addObject:mockNote];
        }
        
        else if ( i == [self.views count] - 2 ||
                  i == [self.views count] - 3)
        {
            
            [note removeFromSuperview];
            
            NoteView * mockNote = [note prototype];
            mockNote.text = note.text;
            
            mockNote.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
            mockNote.bounds = CGRectMake(0,
                                     0,
                                     self.bounds.size.width,
                                     self.bounds.size.height);
            
            int index = [self.views indexOfObject:note];
            
            if (index < [self.views count] - 1)
            {
                [self insertSubview:mockNote
                       belowSubview:self.views[index+1]];
            }
            else
            {
                [self addSubview:mockNote];
            }
            
            CGFloat totalRotation = [self rotationAngleForStacking];
            
            if (i == [self.views count] -2 )
            {
                mockNote.transform = CGAffineTransformRotate(note.transform, -totalRotation);
            }
            else
            {
                
                mockNote.transform = CGAffineTransformRotate(note.transform, totalRotation);
            }
            [tempItems addObject:mockNote];
        }
    }
    self.tempTopItems = tempItems;
}

-(void) cleanupNote:(NoteView *) noteView
{
    [noteView resetSize];
}

-(void) setTopViewForMainView:(NoteView *) mainView
{
    //if the stack has an image note that always has the priority to be
    //the top view over the mainView that was passed as the designated view to the stack
    NoteView * topViewCandidate = nil;
    if ([mainView isKindOfClass:[ImageNoteView class]]){
        topViewCandidate = mainView;
    }
    else
    {
        ImageNoteView * topView = nil;
        for (UIView * view in self.views){
            if ([view isKindOfClass:[ImageNoteView class]]){
                topView = (ImageNoteView *)view;
                break;
            }
        }
        if (topView != nil){
            topViewCandidate = topView;
        }
        else
        {
            topViewCandidate = mainView;
        }
    }
    
    if ([self.views containsObject:topViewCandidate])
    {
        [self.views removeObject:topViewCandidate];
        //set the object as the topview
        [self.views addObject:topViewCandidate];
    }
}

#pragma mark - addition
-(void) addNoteView:(NoteView *) note
{
    [note removeFromSuperview];
    [self.views addObject:note];
}

#pragma mark - deletion
-(void) removeNoteView:(NoteView *)note
{
    if ([self.views containsObject:note])
    {
        [self.views removeObject:note];
        [note removeFromSuperview];
    }
}

#pragma mark - query
-(NSSet *) getAllNoteIds
{
    NSMutableSet * result = [NSMutableSet set];
    for (NoteView * noteView in self.views)
    {
        [result addObject:noteView.ID];
    }
    return result;
}

-(void) scaleWithScaleOffset:(CGFloat)scaleOffset animated:(BOOL)animated
{
    self.scaleOffset = scaleOffset;
    
    //scale yourself
    
    self.bounds = CGRectMake(self.bounds.origin.x,
                             self.bounds.origin.y,
                             self.originalFrame.size.width * scaleOffset,
                             self.originalFrame.size.height * scaleOffset);
    
    //scale the sub noteViews
    
    for(NoteView * view in self.views)
    {
        if (view.superview == self)
        {
            [view scaleWithScaleOffset:scaleOffset
                      fromOriginalSize:CGSizeMake(STACK_WIDTH, STACK_HEIGHT) animated:animated];
            [view scaleWithScaleOffset:scaleOffset animated:animated];
            view.center = CGPointMake((self.bounds.origin.x + self.bounds.size.width) / 2,
            (self.bounds.origin.y + self.bounds.size.height) /2);
        }
    }
    
}

-(void) scale:(CGFloat) scaleFactor animated:(BOOL)animated{
    
    if ( self.frame.size.width * scaleFactor > self.originalFrame.size.width * 2||
        self.frame.size.height * scaleFactor > self.originalFrame.size.height * 2){
        return;
    }
    if ( self.frame.size.width * scaleFactor < self.originalFrame.size.width * 0.9||
        self.frame.size.height * scaleFactor < self.originalFrame.size.height * 0.9){
        return;
    }
    
    self.scaleOffset *= scaleFactor;
    self.bounds = CGRectMake(self.bounds.origin.x,
                             self.bounds.origin.y,
                             self.bounds.size.width * scaleFactor,
                             self.bounds.size.height * scaleFactor);
    for(NoteView * view in self.views)
    {
        if (view.superview == self)
        {
            [view scale:scaleFactor animated:animated];
            view.center = CGPointMake((self.bounds.origin.x + self.bounds.size.width) / 2,
            (self.bounds.origin.y + self.bounds.size.height) /2);
        }
    }
    
}

-(void) resetSize
{
    self.frame = self.originalFrame;
    self.transform = CGAffineTransformIdentity;
    self.scaleOffset = 1;
}

-(void) setTopViewForNote:(NoteView *) newNote;
{
    if ([self.views containsObject:newNote])
    {
        [self.views removeObject:newNote];
        [self.views addObject:newNote];
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

#pragma mark - animations
#define SCALE_SIZE 1.1
#define HIGHLIGHT_DURATION 0.3
#define TRANSLATION_FROM_BASE 20
#define TRANSLATION_DELTA 10
-(void) animateStackHighlighted:(BOOL) highlight
{
    
    //scale the background layer on the stack
    CALayer * stackLayer = self.layer;
    
    CABasicAnimation * selectAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D toTransform = highlight ? CATransform3DMakeScale(SCALE_SIZE, SCALE_SIZE, SCALE_SIZE) : CATransform3DIdentity;
    toTransform.m34 = - 1./500;
    
    
    selectAnimation.fromValue = [NSValue valueWithCATransform3D:stackLayer.transform];
    selectAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
    
    stackLayer.transform = toTransform;
    selectAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    selectAnimation.duration = HIGHLIGHT_DURATION;
    [stackLayer addAnimation:selectAnimation forKey:@"scaleAnimation"];
    
    
    int noteNo = 0;
    for(NoteView * note in self.views)
    {
        if (note.superview == self)
        {
            CALayer * noteLayer = note.layer;
            [CABasicAnimation animationWithKeyPath:@"transform"];
            CATransform3D noteToTransform;
            if (highlight)
            {
                //rotate all back to their current place
                noteToTransform = CATransform3DIdentity;
                CGFloat translation = TRANSLATION_FROM_BASE - noteNo * TRANSLATION_DELTA;
                noteToTransform = CATransform3DTranslate(noteToTransform, translation,
                                                     translation,
                                                     translation);
            }
            else
            {
                int index = [self.views indexOfObject:note];
                //top view
                CGFloat rotationAngle = 0;
                
                if (index == self.views.count - 2)
                {
                    rotationAngle = [self rotationAngleForStacking];
                }
                
                if (index == self.views.count - 3)
                {
                    rotationAngle = - [self rotationAngleForStacking];
                }
                
                noteToTransform = CATransform3DRotate(noteLayer.transform,
                                                  rotationAngle,
                                                  0, 0, 1);
                
                CGFloat translation = -(TRANSLATION_FROM_BASE - noteNo * TRANSLATION_DELTA);
                
                noteToTransform = CATransform3DTranslate(noteToTransform, translation,
                                                     translation,
                                                     translation);
            }
            
            CABasicAnimation * noteAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            noteAnimation.fromValue = [NSValue valueWithCATransform3D:noteLayer.transform];
            noteAnimation.toValue = [NSValue valueWithCATransform3D:noteToTransform];
            
            noteLayer.transform = noteToTransform;
            noteAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            noteAnimation.duration = HIGHLIGHT_DURATION;
            [noteLayer addAnimation:noteAnimation forKey:@"noteTransform"];
            noteNo++;
        }
        
    }
    
//    CABasicAnimation * shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
//    CGSize toValue = CGSizeMake(layer.shadowOffset.width,
//                                layer.shadowOffset.height + HIGHLIGHT_SHADOW_ADDITON_Y);
//    
//    shadowAnimation.fromValue = [NSValue valueWithCGSize:layer.shadowOffset];
//    shadowAnimation.toValue = [NSValue valueWithCGSize:toValue];
//    
//    layer.shadowOffset = toValue;
//    shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    shadowAnimation.duration = HIGHLIGHT_DURATION;
//    [layer addAnimation:shadowAnimation forKey:@"shadowOffset"];
//    
//    CABasicAnimation * shadowRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
//    shadowRadiusAnimation.fromValue = [NSNumber numberWithFloat:layer.shadowRadius];
//    shadowRadiusAnimation.toValue = [NSNumber numberWithFloat:layer.shadowRadius + HIGHLIGHT_ADDITONAL_RADIUS];
//    
//    layer.shadowRadius = layer.shadowRadius + HIGHLIGHT_ADDITONAL_RADIUS;
//    shadowRadiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    shadowRadiusAnimation.duration = HIGHLIGHT_DURATION;
//    [layer addAnimation:shadowRadiusAnimation forKey:@"shadowRadius"];
}


@end
