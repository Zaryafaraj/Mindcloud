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


@interface CollectionLayoutHelper : NSObject
-(id) initWithNoteWidth: (float) noteWidth
              andHeight:(float) noteHeight;

-(void) adjustNotePositionsForX:(float *) positionX
                           andY:(float *) positionY
                         inView:(UIView *) collectionView;

-(UIView *) gatherNoteViewFor:(NSArray *) noteRefIDs
           fromCollectionView:(UIView *) collectionView
                         into:(NSMutableArray *) views;

-(CGRect) findFittingRectangle: (StackView *) stack inView:(UIView *) collectionView;

-(NSArray *) checkForOverlapWithView: (UIView *) senderView
                    inCollectionView: (UIView *) collectionView;

-(CGRect) findFittingRectangle: (StackView *) stack
                        inView:(UIView *) collectionView;

- (CGRect) getStackingFrameForStackingWithTopView: (UIView *) mainView;

-(void) clearRectangle:(CGRect) rect
      inCollectionView:(UIView *)collectionView
  withMoveNoteFunction:(update_note_location_function) updateNote;

-(void) expandNotes:(NSArray *) items
             inRect:(CGRect) rect
withMoveNoteFunction:(update_note_location_function) updateNote;

@end
