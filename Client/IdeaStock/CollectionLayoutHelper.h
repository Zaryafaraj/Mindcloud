//
//  CollectionLayoutHelper.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"
#import "StackView.h"
#import "FunctionTypeDefs.h"
#import "CollectionAnimationHelper.h"


#define OVERLAP_RATIO 0.35
#define EXIT_OFFSET_RATIO 0.1
#define SEPERATOR_RATIO 0.1
#define EXPAND_COL_SIZE 5
#define STACKING_SCALING_WIDTH 1.1
#define STACKING_SCALING_HEIGHT 1.05
#define NOTE_WIDTH 200
#define NOTE_HEIGHT 200

@interface CollectionLayoutHelper : NSObject

+(void) adjustNotePositionsForX:(float *) positionX
                           andY:(float *) positionY
                         inView:(UIView *) collectionView;

+(CGRect) findFittingRectangle: (StackView *) stack inView:(UIView *) collectionView;

+(NSArray *) checkForOverlapWithView: (UIView *) senderView
                    inCollectionView: (UIView *) collectionView;

+(CGRect) findFittingRectangle: (StackView *) stack
                        inView:(UIView *) collectionView;

+(CGRect) getStackingFrameForStackingWithTopView: (UIView *) mainView;

+(void) clearRectangle:(CGRect) rect
      inCollectionView:(UIView *)collectionView
  withMoveNoteFunction:(update_note_location_function) updateNote;

+(void) expandNotes:(NSArray *) items
             inRect:(CGRect) rect
withMoveNoteFunction:(update_note_location_function) updateNote;

+(void) layoutViewsForOrientationChange:(UIView *) collectionView;

+(CGRect) getFrameForNewNote:(UIView *) view
                AddedToPoint: (CGPoint) location
                        InCollectionView:(UIView *) collectionView;

+(void) removeNote:(NoteView *) noteItem
           fromStack:(StackView *) stack
    InCollectionView: (UIView *) collectionView withCountInStack:(int) count
         andCallback:(layout_unstack_finished)callback;

+(void) updateViewLocationForView:(UIView *) view
                 inCollectionView:(UIView *) collectionView;
@end
