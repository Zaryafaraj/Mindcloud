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
    note.transform = CGAffineTransformScale(note.transform, 0.10, 0.10);
    note.alpha = 1;
    
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.4
          initialSpringVelocity:2.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         note.transform = CGAffineTransformScale(note.transform, 10, 10);
                         //note.alpha = 1;
                         
                     }completion:nil];
                         
    
    [collectionView addSubview:note];
}

+(void) animateStackViewRemoval:(StackView *) stack
{
    [UIView animateWithDuration:0.25
                     animations:^{ stack.alpha = 0 ;}
                     completion:^(BOOL finished){[stack removeFromSuperview];}];
}

+(void) animateExpandNote: (UIView *) note
            InRect:(CGRect) noteRect
{
    CGPoint newCenter = CGPointMake(noteRect.origin.x + noteRect.size.width / 2,
                                    noteRect.origin.y + noteRect.size.height / 2);
    [UIView animateWithDuration:0.5 animations:^{note.center = newCenter;}];
}

+(void) animateMoveNote:(UIView *) view
backIntoScreenBoundsInRect:(CGRect) frame
{
    
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGPoint centerPoint = CGPointMake(frame.origin.x + frame.size.width/2,
                                                           frame.origin.y + frame.size.height/2);
                         view.center = centerPoint;
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
            [UIView animateWithDuration:1 animations:^
            {
                CGPoint newCenter = CGPointMake(finalRect.origin.x + finalRect.size.width/2,
                                                finalRect.origin.y + finalRect.size.height/2);
                noteView.center = newCenter;
            }];
            callback();
        }];
}

+(void) animateMoveNoteOutOfExpansion:(UIView *) note
                              toFrame:(CGRect) frame
{
    
    CGPoint centerPoint = CGPointMake(frame.origin.x + frame.size.width/2,
                                      frame.origin.y + frame.size.height/2);
    [UIView animateWithDuration:0.25 animations:^{note.center = centerPoint ;}];
}

+(void) animateMoveView:(UIView *) view
              intoCenter:(CGPoint) center
           inCollection:(UIView *) collectionView
{
    
    [UIView animateWithDuration:0.25 animations:^{view.center = center;}];
}

+(void) animateMoveView:(UIView *) view
              intoCenter:(CGPoint) center
           inCollection:(UIView *) collectionView
         withCompletion:(move_noted_finished) callback
{
    
    [UIView animateWithDuration:0.25 animations:^{
        view.center = center;
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

