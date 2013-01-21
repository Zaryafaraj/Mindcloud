//
//  CollectionAnimationHelper.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/20/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteView.h"
#import "StackView.h"
#import "FunctionTypeDefs.h"

@interface CollectionAnimationHelper : NSObject

+(void) animateNoteAddition:(NoteView *)note
               toCollectionView:(UIView *) collectionView;

+(void) animateStackViewRemoval:(StackView *) stack;

+(void) animateStackCreationForStackView:(UIView *) stack
                            WithMainView:(UIView *) mainView
                            andStackItems:(NSArray*) items
                        inCollectionView: (UIView *) collectionView
                                   isNew:(BOOL) isNewStack
                    withMoveNoteFunction:(update_note_location_function) updateNote;

+(void) animateExpandNote: (UIView *) note
            InRect:(CGRect) noteRect;

+(void) animateMoveNoteOutOfExpansion:(UIView *) note
                              toFrame:(CGRect) frame;

+(void) animateMoveNote:(UIView *) view
backIntoScreenBoundsInRect:(CGRect) frame;

+(void) animateDeleteView:(UIView *) view
       fromCollectionView:(UIView *) collectionView
  withCallbackAfterFinish:(animate_delete_finished) callback;

+(void) animateUnstack:(NoteView *) noteView
             fromStack:(StackView *) stack
          inCollection:(UIView *) collectionView
         withFinalRect:(CGRect) finalRect
    withFinishCallback:(animate_unstack_finished) callback;
@end
