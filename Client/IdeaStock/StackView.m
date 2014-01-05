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
#import "ThemeFactory.h"

#define MAX_VISIBLE_NOTES 3
#define STACKING_DURATION 0.3

@interface StackView()

@property CGRect originalFrame;
@property NSMutableArray * tempTopItems;
@property UIButton * deleteButton;
@property UIButton * expandButton;

//this is like a queue that make sure all the animations are finished before
//ordering the items on the view. Because animations may finish on different
//times and based on when they finish they add a note as a subview. We will have
//a non deterministic situation of what not will be on top of which
//the solution is to wait until all animations are completed and the order the subView
@property (atomic, assign) int finishedCount;

@end

@implementation StackView

@synthesize text = _text;
@synthesize highlighted = _highlighted;
@synthesize ID = _ID;
@synthesize scaleOffset = _scaleOffset;
@synthesize rotationOffset = _rotationOffset;
@synthesize selectedInStack = _selectedInStack;

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
    [self createDeleteButton];
    [self createExpandButton];
    [self animateStackHighlighted:highlighted];
}

-(void) createDeleteButton
{
    if (!self.deleteButton)
    {
        UIButton * delButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.deleteButton = delButton;
        [self.deleteButton addTarget:self
                              action:@selector(deletePressed:)
                    forControlEvents:UIControlEventTouchDown];
        
        UIImage * btnImage = [[ThemeFactory currentTheme] imageForDeleteIcon];
        [self.deleteButton setImage:btnImage
                           forState:UIControlStateNormal];
        [self addSubview:self.deleteButton];
        self.deleteButton.frame = CGRectMake(10, 10 , 40, 40);
        self.deleteButton.tintColor = [[ThemeFactory currentTheme] tintColorForDeleteIcon];
    }
}

-(void) createExpandButton
{
    if (!self.expandButton)
    {
        UIButton * expandButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.expandButton = expandButton;
        [self.expandButton addTarget:self
                              action:@selector(expandPressed:)
                    forControlEvents:UIControlEventTouchDown];
        
        UIImage * btnImage = [[ThemeFactory currentTheme] imageForExpand];
        [self.expandButton setImage:btnImage
                           forState:UIControlStateNormal];
        self.expandButton.tintColor = [[ThemeFactory currentTheme] tintColorForDeleteIcon];
        [self addSubview:self.expandButton];
        self.expandButton.frame = CGRectMake(0, 0 , 40, 40);
        self.expandButton.hidden = YES;
    }
}
-(void) deletePressed:(id) sender
{
    id<StackActionDelegate> temp = self.delegate;
    if(temp)
    {
        [temp deleteStackPressed:self];
    }
}

-(void) expandPressed:(id) sender
{
    id<StackActionDelegate> temp = self.delegate;
    if(temp)
    {
        [temp expandStackPressed:self];
    }
}

-(void) rotate:(CGFloat)rotation
{
    //nothing to do in stack view
}



//Stack view consists of a bigger transparetn view which includes at most the top 3 notes

-(id) initWithViews: (NSMutableArray *) views 
        andMainView: (NoteView *) mainView
          withFrame: (CGRect) frame
         andScaling:(CGFloat) scaleOffset
{
    self = [super initWithFrame:frame];
//    self.backgroundColor = [UIColor greenColor];
    
    if (self)
    {
        self.finishedCount = 0;
        self.views = views;
        //determine the topview
        [self setTopViewForMainView:mainView];
        self.originalFrame = self.frame;
        self.scaleOffset = scaleOffset;
        
        //scale yourself
        self.bounds = CGRectMake(self.bounds.origin.x,
                                 self.bounds.origin.y,
                                 self.originalFrame.size.width * scaleOffset,
                                 self.originalFrame.size.height * scaleOffset);
        [self layoutStackView];
    }
    //self.backgroundColor = [UIColor darkGrayColor];
    return self;
}

-(CGFloat) rotationAngleForStacking
{
    return M_PI_4 * 1/8;
}

-(void) setTopItem:(NoteView *) note
{
    if (self.tempTopItems.count > 0)
    {
        NoteView * noteView = self.tempTopItems.lastObject;
        noteView.text = note.text;
    }
    
    //make sure we set the item we have just touch as the main view and
    //toward the end of the array
   int index = [self.views indexOfObject:note];
    if (index >= 0)
    {
        NSMutableArray * newViews = [self.views mutableCopy];
        [newViews removeObject:note];
        [newViews addObject:note];
        self.views = newViews;
    }
    
}
-(void) animateStackingOfTopItem:(NoteView *) note
{
    
    CGRect aBound = CGRectMake(0,
                               0,
                               self.bounds.size.width - 2 * NOTE_OFFSET_FROM_STACKING,
                               self.bounds.size.height - 2 * NOTE_OFFSET_FROM_STACKING);
    
    UIViewAnimationOptions option = UIViewAnimationOptionCurveEaseIn;
    [note animateLayoutChangeForBounds:aBound
                          withDuration:STACKING_DURATION
                   andAnimationOptions:option];
    
    [UIView animateWithDuration:STACKING_DURATION delay:0
                        options:option
                     animations:^{
                         note.transform = CGAffineTransformIdentity;
                         note.bounds = aBound;
                         note.center = self.center;
                     }completion:^(BOOL finished){
                         [note removeFromSuperview];
                         [self addSubview:note];
                         note.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                         [self animationFinished];
                     }
     ];
}


-(void) animateStackingOfBelowItems:(NoteView *) note
                  withRotationAngle:(CGFloat) angle
{
    
    CGRect aBound = CGRectMake(0,
                               0,
                               self.bounds.size.width - 2 * NOTE_OFFSET_FROM_STACKING,
                               self.bounds.size.height - 2 * NOTE_OFFSET_FROM_STACKING);
    UIViewAnimationOptions option = UIViewAnimationOptionCurveEaseIn;
    [note animateLayoutChangeForBounds:aBound
                          withDuration:STACKING_DURATION
                   andAnimationOptions:option];
    
    [UIView animateWithDuration:STACKING_DURATION
                          delay:0
                        options:option
                     animations:^{
                         CGFloat rotationRight = angle;
                         CGFloat totalRotation = rotationRight;
                         note.transform = CGAffineTransformRotate(CGAffineTransformIdentity, totalRotation);
                         
                         
                         note.bounds = aBound;
                         note.center = self.center;
                     }completion:^(BOOL finished){
                         
                         [note removeFromSuperview];
                         [self addSubview:note];
                         
                         note.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                         
                         [self animationFinished];
                         
                     }
     ];
}

-(void) animationFinished
{
    self.finishedCount++;
    int maxCount = self.views.count >= 3 ? 3 : 2;
    if (self.finishedCount == maxCount)
    {
        
        UIView * topView = self.views[self.views.count - 1];
        [self addSubview:topView];
        if (self.views.count >= 3)
        {
            UIView * viewToAdd = self.views[self.views.count - 3];
            [self insertSubview:viewToAdd belowSubview:topView];
        }
        if (self.views.count >= 2)
        {
            UIView * viewToAdd = self.views[self.views.count - 2];
            [self insertSubview:viewToAdd belowSubview:topView];
        }
    }
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
        note.rotationOffset = 1;
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
        
        CGRect aBound = CGRectMake(0,
                                   0,
                                   self.bounds.size.width - 2 * NOTE_OFFSET_FROM_STACKING,
                                   self.bounds.size.height - 2 * NOTE_OFFSET_FROM_STACKING);
        
        note.bounds = aBound;
        note.center = CGPointMake(self.frame.size.width/2,
                                  self.frame.size.height/2);
        
        
        if (self.views.count >= 1 &&
            i == self.views.count - 1)
        {
            [self addSubview:note];
        }
        if (self.views.count >= 2 &&
            i == [self.views count] -2 )
        {
            [self addSubview:note];
            CGFloat totalRotation = [self rotationAngleForStacking];
            note.transform = CGAffineTransformRotate(note.transform, +totalRotation);
        }
        if (self.views.count >= 3 &&
            i == [self.views count] - 3 )
        {
            [self addSubview:note];
            CGFloat totalRotation = [self rotationAngleForStacking];
            note.transform = CGAffineTransformRotate(note.transform, -totalRotation);
        }
        else if (self.views.count >= 3 &&
                 i < self.views.count - 3)
        {
            [note resetSize];
        }
    }
}

-(void) stackWillOpen
{
    
    NSMutableArray * tempItems = [NSMutableArray arrayWithCapacity:MAX_VISIBLE_NOTES];
    int count = self.views.count;
    for (int i = self.views.count - 3; i < count; i++)
    {
        
        if (i >=0 )
        {
            NoteView * note = self.views[i];
            //if its the top of the stack move it on top without rotation
            
            [note removeFromSuperview];
            NoteView * mockNote = [note prototype];
            mockNote.hidden = NO;
            mockNote.text = note.text;
            
            mockNote.center = note.center;
            mockNote.bounds = CGRectMake(0,
                                         0,
                                         note.bounds.size.width,
                                         note.bounds.size.height);
            
            mockNote.transform = note.transform;
            
            [self addSubview:mockNote];
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
    if (mainView == nil) return;
    
    //if main view is not at the end of the views array put it there
    if ([self.views indexOfObject:mainView] != self.views.count - 1)
    {
        [self.views removeObject:mainView];
        [self.views addObject:mainView];
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
//            [view scaleWithScaleOffset:scaleOffset animated:animated];
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
            
            [view scaleWithScaleOffset:self.scaleOffset
                      fromOriginalSize:CGSizeMake(STACK_WIDTH, STACK_HEIGHT) animated:animated];
            //[view scale:scaleFactor animated:animated];
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
#define TRANSLATION_FROM_BASE 40
#define TRANSLATION_DELTA 15
#define HIGHLIGHT_SHADOW_ADDITON_X 3
#define HIGHLIGHT_SHADOW_ADDITON_Y 3
#define HIGHLIGHT_ADDITONAL_RADIUS 3

-(void) animateStackHighlighted:(BOOL) highlight
{
    
    //scale the background layer on the stack
    CALayer * stackLayer = self.layer;
    
    CABasicAnimation * selectAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D toTransform = highlight ? CATransform3DMakeScale(SCALE_SIZE, SCALE_SIZE, 1) : CATransform3DIdentity;
    
    
    selectAnimation.fromValue = [NSValue valueWithCATransform3D:stackLayer.transform];
    selectAnimation.toValue = [NSValue valueWithCATransform3D:toTransform];
    
    stackLayer.transform = toTransform;
    selectAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    selectAnimation.duration = HIGHLIGHT_DURATION;
    [stackLayer addAnimation:selectAnimation forKey:@"scaleAnimation"];
    
    CGPoint deleteCenter = CGPointMake(INFINITY, INFINITY);
    
    int noteNo = MAX_VISIBLE_NOTES - 1;
    for(NoteView * note in self.views)
    {
        if (note.superview == self)
        {
            UIView * enclosingNote = [note getEnclosingNoteView];
            CALayer * enclosingNoteLayer = enclosingNote.layer;
            CGFloat newShadowOffset = 0;
            CGFloat newShadowRadius = 0;
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
                                                     0);
                newShadowOffset = enclosingNoteLayer.shadowOffset.height + HIGHLIGHT_SHADOW_ADDITON_Y;
                newShadowRadius = enclosingNoteLayer.shadowRadius + HIGHLIGHT_ADDITONAL_RADIUS;
                
            }
            else
            {
                int index = [self.views indexOfObject:note];
                //top view
                CGFloat rotationAngle = 0;
                
                if (index == self.views.count - 2 && note != self.mainView)
                {
                    rotationAngle = [self rotationAngleForStacking];
                }
                
                if (index == self.views.count - 3 && note != self.mainView)
                {
                    rotationAngle = - [self rotationAngleForStacking];
                }
                
                noteToTransform = CATransform3DRotate(noteLayer.transform,
                                                  rotationAngle,
                                                  0, 0, 1);
                
                CGFloat translation = -(TRANSLATION_FROM_BASE - noteNo * TRANSLATION_DELTA);
                
                noteToTransform = CATransform3DTranslate(noteToTransform, translation,
                                                     translation,
                                                     0);
                
                newShadowOffset = enclosingNoteLayer.shadowOffset.height - HIGHLIGHT_SHADOW_ADDITON_Y;
                newShadowRadius = enclosingNoteLayer.shadowRadius - HIGHLIGHT_ADDITONAL_RADIUS;
                
            }
            
            if (YES)
            {
                CABasicAnimation * noteAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
                noteAnimation.fromValue = [NSValue valueWithCATransform3D:noteLayer.transform];
                noteAnimation.toValue = [NSValue valueWithCATransform3D:noteToTransform];
                
                noteLayer.transform = noteToTransform;
                noteAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                noteAnimation.duration = HIGHLIGHT_DURATION;
                [noteLayer addAnimation:noteAnimation forKey:@"noteTransform"];
            }
            noteNo--;
            
            CGPoint orginInNoteView = enclosingNote.frame.origin;
            CGPoint originInSelf = [self convertPoint:orginInNoteView fromView:note];
            if (originInSelf.x < deleteCenter.x)
            {
                
                deleteCenter = CGPointMake(originInSelf.x,
                                           originInSelf.y);
                
                
            }
            
            CABasicAnimation * shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOffset"];
            
            CGSize toValue = CGSizeMake(noteLayer.shadowOffset.width, newShadowOffset);
                                        
            shadowAnimation.fromValue = [NSValue valueWithCGSize:enclosingNoteLayer.shadowOffset];
            shadowAnimation.toValue = [NSValue valueWithCGSize:toValue];
            
            enclosingNoteLayer.shadowOffset = toValue;
            shadowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            shadowAnimation.duration = HIGHLIGHT_DURATION;
            [enclosingNoteLayer addAnimation:shadowAnimation forKey:@"shadowOffset"];
            
            CABasicAnimation * shadowRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"shadowRadius"];
            shadowRadiusAnimation.fromValue = [NSNumber numberWithFloat:enclosingNoteLayer.shadowRadius];
            shadowRadiusAnimation.toValue = [NSNumber numberWithFloat:newShadowRadius];
            enclosingNoteLayer.shadowRadius = newShadowRadius;
            shadowRadiusAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            shadowRadiusAnimation.duration = HIGHLIGHT_DURATION;
            [enclosingNoteLayer addAnimation:shadowRadiusAnimation forKey:@"shadowRadius"];
            
            
            
        }
        
    }
    if (highlight)
    {
        
        [self addSubview:self.deleteButton];
        self.deleteButton.hidden = NO;
        self.deleteButton.center = deleteCenter;
        self.deleteButton.transform = CGAffineTransformIdentity;
        self.deleteButton.transform = CGAffineTransformScale(self.deleteButton.transform, 0.1, 0.1);
        
        [self addSubview:self.expandButton];
        self.expandButton.hidden = NO;
        self.expandButton.center = CGPointMake(deleteCenter.x + (45 * self.scaleOffset),
                                               deleteCenter.y);
        self.expandButton.transform = CGAffineTransformIdentity;
        self.expandButton.transform = CGAffineTransformScale(self.expandButton.transform, 0.1, 0.1);
        [UIView animateWithDuration:0.6
                              delay:0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.deleteButton.transform = CGAffineTransformScale(self.deleteButton.transform, 10 * self.scaleOffset, 10 * self.scaleOffset);
                             
                             self.expandButton.transform = CGAffineTransformScale(self.expandButton.transform, 10 * self.scaleOffset, 10 * self.scaleOffset);
                         }completion:^(BOOL completed){
                         }];
    }
    else
    {
        
        [UIView animateWithDuration:0.4
                              delay:0
             usingSpringWithDamping:0.8
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.deleteButton.transform = CGAffineTransformScale(self.deleteButton.transform, 0.001 * 1/self.scaleOffset, 0.001 * 1/self.scaleOffset);
                             
                             self.expandButton.transform = CGAffineTransformScale(self.expandButton.transform, 0.001 * 1/self.scaleOffset, 0.001 * 1/self.scaleOffset);
                         }completion:^(BOOL completed){
                             self.deleteButton.hidden = YES;
                             self.expandButton.hidden = YES;
                         }];
    }
}


@end
