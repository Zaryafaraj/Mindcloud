//
//  CollectionAnimationHelper.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/20/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionAnimationHelper.h"

@implementation CollectionAnimationHelper

+(void) animateNoteAddition:(NoteView *)note
               toCollectionView:(UIView *) collectionView
{
    note.transform = CGAffineTransformScale(note.transform, 10, 10);
    note.alpha = 0;
    
    [UIView animateWithDuration:0.25 animations:^{
        note.transform = CGAffineTransformScale(note.transform, 0.1, 0.1);
        note.alpha = 1;
    }];
    
    [collectionView addSubview:note];
}

+(void) animateStackViewRemoval:(StackView *) stack
{
    [UIView animateWithDuration:0.25
                     animations:^{ stack.alpha = 0 ;}
                     completion:^(BOOL finished){[stack removeFromSuperview];}];
}

+(void) animateStackCreationForStackView:(UIView *) stack
                            WithDestinationView:(UIView *) destView
                            andStackItems:(NSArray*) items
                        inCollectionView: (UIView *) collectionView
                                   isNew:(BOOL) isNewStack
                    withMoveNoteFunction:(update_note_location_function) updateNote
{
    
//    [UIView animateWithDuration:0.5 animations:^{mainView.alpha = 0;}];
//    [mainView removeFromSuperview];
    destView.alpha = 1;
    stack.alpha =0;
    [collectionView addSubview:stack];
    [UIView animateWithDuration:0.5 animations:^{stack.alpha = 1;}];
    
    
    for (UIView * view in items){
        
         if ([view isKindOfClass:[NoteView class]]){
             if (isNewStack){
                 updateNote((NoteView *) view);
             }
         }
        [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 [view setFrame:destView.frame];
                             }
                             completion:^(BOOL finished){
                                 [view removeFromSuperview];
                            }];
        }
}

+(void) animateStackCreationForStackView:(StackView *) stack
                            WithMainView:(UIView *) mainView
                        inCollectionView: (UIView *) collectionView
{
    mainView.alpha = 1;
    stack.alpha =0;
    for (UIView * view in stack.views)
    {
        [UIView animateWithDuration:0.25
                         animations:^{view.alpha = 0;}
                         completion:^(BOOL finished){
                             [view removeFromSuperview];
                             view.alpha = 1;}];
    }
    [collectionView addSubview:stack];
    [UIView animateWithDuration:0.5 animations:^{stack.alpha = 1;}];
}

+(void) animateExpandNote: (UIView *) note
            InRect:(CGRect) noteRect
{
    [UIView animateWithDuration:0.5 animations:^{note.frame = noteRect;}];
}

+(void) animateMoveNote:(UIView *) view
backIntoScreenBoundsInRect:(CGRect) frame
{
    
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                view.frame = frame;
    }
                     completion:nil];
}

+(void) animateDeleteView:(UIView *) view
       fromCollectionView:(UIView *) collectionView
  withCallbackAfterFinish:(animate_delete_finished) callback;
{
    [UIView animateWithDuration:0.5 animations:^{
        view.transform = CGAffineTransformScale(view.transform, 0.05, 0.05);
    }completion:^ (BOOL didFinish){
        callback();
    }];
}

+(void) animateUnstack:(NoteView *) noteView
             fromStack:(StackView *) stack
          inCollection:(UIView *) collectionView
         withFinalRect:(CGRect) finalRect
    withFinishCallback:(animate_unstack_finished) callback
{
    
        [UIView animateWithDuration:0.5 animations:^{ noteView.alpha = 1;} completion:^(BOOL isFinished){
            [UIView animateWithDuration:1 animations:^{noteView.frame = finalRect;}];
            callback();
        }];
}

+(void) animateMoveNoteOutOfExpansion:(UIView *) note
                              toFrame:(CGRect) frame
{
    
    [UIView animateWithDuration:0.25 animations:^{note.frame = frame;}];
}

+(void) animateMoveView:(UIView *) view
              intoFrame:(CGRect) frame
           inCollection:(UIView *) collectionView
{
    
    [UIView animateWithDuration:0.25 animations:^{view.frame = frame;}];
}

+(void) animateMoveView:(UIView *) view
              intoFrame:(CGRect) frame
           inCollection:(UIView *) collectionView
         withCompletion:(move_noted_finished) callback
{
    
    [UIView animateWithDuration:0.25 animations:^{
        view.frame = frame;
    }completion:^(BOOL finished){
        callback();
    }];
}

+(void) animateScaleView:(UIView *) view
               withScale:(float) scale
            inCollection:(UIView *) collectionView
{
    
    [UIView animateWithDuration:0.5 animations:^{
        view.transform = CGAffineTransformScale(view.transform, scale, scale);
    }];
}

+(void) animateChangeFrame:(UIView *) view
              withNewFrame:(CGRect) newFrame
{
    [UIView animateWithDuration:0.25 animations:^{
        view.frame = newFrame;
    }];
}
@end

