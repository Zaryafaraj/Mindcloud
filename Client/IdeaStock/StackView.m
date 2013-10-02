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

#define MAX_VISIBLE_NOTES 3
#define STACKING_DURATION 1
@interface StackView()

@property CGRect originalFrame;

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
//    int lastIndex = self.views.count - 1;
//    for (int i = 0; i < MAX_VISIBLE_NOTES; i++)
//    {
//        int topIndex = lastIndex - i;
//        if (topIndex >= 0)
//        {
//            ((NoteView *) self.views[topIndex]).highlighted = highlighted;
//        }
//    }
}


-(void) rotate:(CGFloat)rotation
{
    //nothing to do in stack view
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
    
    return self;
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
        
        //if its the top of the stack move it on top without rotation
        if (i == [self.views count] - 1)
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
                                 
                                 note.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                                 note.bounds = CGRectMake(0,
                                                          0,
                                                          self.bounds.size.width,
                                                          self.bounds.size.height);
                                 
                                [self addSubview:note];
                             }
             ];
        }
        
        //rotate the second to top to the right
        else if ( i == [self.views count] - 2)
        {
            
            [UIView animateWithDuration:STACKING_DURATION delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 CGFloat currentRotation = note.rotationOffset;
                                 CGFloat rotationRight = - M_PI_4 * 1/8;
                                 CGFloat totalRotation = rotationRight - currentRotation;
                                 note.transform = CGAffineTransformRotate(note.transform, totalRotation);
                                 
                                 note.center = self.center;
                             }completion:^(BOOL finished){
                                 
                                 [note removeFromSuperview];
                                 
                                 
                                 note.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                                 note.bounds = CGRectMake(0,
                                                          0,
                                                          self.bounds.size.width,
                                                          self.bounds.size.height);
                                 
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
        
        //rotate the third to top to the left
        else if ( i == [self.views count] - 3)
        {
            
            [UIView animateWithDuration:STACKING_DURATION delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 CGFloat currentRotation = note.rotationOffset;
                                 // PI / 6
                                 CGFloat rotationRight = + M_PI_4 * 1/8;
                                 CGFloat totalRotation = rotationRight - currentRotation;
                                 
                                 note.transform = CGAffineTransformRotate(note.transform, totalRotation);
                                 
                                 note.center = self.center;
                             }completion:^(BOOL finished){
                                 
                                 [note removeFromSuperview];
                                 
                                 
                                 note.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                                 note.bounds = CGRectMake(0,
                                                          0,
                                                          self.bounds.size.width,
                                                          self.bounds.size.height);
                                 
                                 
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
        
        //for the rest no extra operations are needed
        else
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
        
    }
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
    for (UIView * noteView in self.subviews)
    {
        if ([noteView isKindOfClass:[NoteView class]])
        {
            [((NoteView *) noteView) scaleWithScaleOffset:scaleOffset animated:animated];
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
@end
