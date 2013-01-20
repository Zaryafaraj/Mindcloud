//
//  CollectionLayoutHelper.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"
#import "StackView.h"


#define OVERLAP_RATIO 0.35
#define EXIT_OFFSET_RATIO 0.1
#define SEPERATOR_RATIO 0.1
#define EXPAND_COL_SIZE 5

@interface CollectionLayoutHelper : MindcloudBaseAction

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


@end
