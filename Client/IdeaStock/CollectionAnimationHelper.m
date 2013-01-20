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
                            WithMainView:(UIView *) mainView
                            andStackItems:(NSArray*) items
                        inCollectionView: (UIView *) collectionView
                                   isNew:(BOOL) isNewStack
                    withMoveNoteFunction:(update_note_location_function) updateNote
{
    
    [UIView animateWithDuration:0.5 animations:^{mainView.alpha = 0;}];
    [mainView removeFromSuperview];
    mainView.alpha = 1;
    stack.alpha =0;
    [collectionView addSubview:stack];
    [UIView animateWithDuration:0.5 animations:^{stack.alpha = 1;}];
    
    
    for (UIView * view in items){
        if (view != mainView){
            [UIView animateWithDuration:0.5
                                  delay:0 options:UIViewAnimationCurveEaseOut
                             animations:^{
                                 [view setFrame:mainView.frame];
                             }
                             completion:^(BOOL finished){
                                 if ([view isKindOfClass:[NoteView class]]){
                                     if (isNewStack){
                                         updateNote((NoteView *) view);
                                     }
                                 }
                                 [view removeFromSuperview];
                            }];
        }
    }    
}

+(void) animateExpandNote: (UIView *) note
            InRect:(CGRect) noteRect
{
    [UIView animateWithDuration:0.5 animations:^{note.frame = noteRect;}];
}

+(void) animateMoveNote:(UIView *) view
backIntoScreenBoundsInRect:(CGRect) frame
{
    
            [UIView animateWithDuration:0.1 animations:^{
                view.frame = frame;
            }];
}
@end

