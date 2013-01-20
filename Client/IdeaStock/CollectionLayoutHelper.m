//
//  CollectionLayoutHelper.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionLayoutHelper.h"
#import "NoteView.h"
#import "BulletinBoardObject.h"

@interface CollectionLayoutHelper()

@property float noteWidth;
@property float noteHeight;

@end
@implementation CollectionLayoutHelper

-(id) initWithNoteWidth:(float)noteWidth andHeight:(float)noteHeight
{
    self = [super init];
    self.noteHeight = noteHeight;
    self.noteWidth = noteWidth;
    return self;
}

-(void) adjustNotePositionsForX:(float *) positionX
                           andY:(float *) positionY
                         inView:(UIView *) collectionView
{
    
        float maxWidth = collectionView.frame.origin.x + collectionView.frame.size.width;
        float maxHeight = collectionView.frame.origin.y + collectionView.frame.size.height;
    
        if ( *positionX + self.noteWidth > maxWidth ){
            *positionX = collectionView.frame.origin.x + collectionView.frame.size.width - self.noteWidth;
        }
        if ( *positionY + self.noteHeight> maxHeight){
            *positionY = collectionView.frame.origin.x + collectionView.frame.size.height - self.noteHeight;
        }
        if (*positionX <  collectionView.frame.origin.x){
            *positionX = collectionView.frame.origin.x;
        }
        if (*positionY < collectionView.frame.origin.y){
            *positionY = collectionView.frame.origin.y;
        }
}

-(BOOL) doesView: (UIView *) view1
 OverlapWithView: (UIView *) view2
{
    
    CGPoint view1Center = CGPointMake(view1.frame.origin.x + (view1.frame.size.width/2), 
                                        view1.frame.origin.y + (view1.frame.size.height/2) );
    CGPoint view2Center = CGPointMake(view2.frame.origin.x + (view2.frame.size.width/2), 
                                      view2.frame.origin.y + (view2.frame.size.height/2) );
    
    CGFloat dx = view1Center.x - view2Center.x;
    CGFloat dy = view1Center.y - view2Center.y;
    
    float distance = sqrt(dx*dx + dy*dy);
    if ( distance < OVERLAP_RATIO * self.noteWidth){
        return YES;
    }
    return NO;
}


-(UIView *) gatherNoteViewFor:(NSArray *) noteRefIDs
           fromCollectionView:(UIView *) collectionView
                         into:(NSMutableArray *) views
{
    NSSet * noteRefs = [[NSSet alloc] initWithArray:noteRefIDs];
    UIView * mainView;
    for (UIView * view in collectionView.subviews){
        if ([view isKindOfClass:[NoteView class]]){
            NSString * noteID = ((NoteView *) view).ID;
            if ([noteRefs containsObject:noteID]){
                [views addObject:view];
                //make sure that the latest note added will be shown on the top of the stacking
                if ([noteID isEqualToString:noteRefIDs[0]]){
                    mainView = view;
                }
            }
        }
    }
    
    //return the head of the views
    return mainView;
}


-(CGSize) getRectSizeForStack: (StackView *) stack
             inCollectionView:(UIView *) collectionView{
    
    int notesInStack = [stack.views count];
    
    //get the number of rows in expanded state
    int numberOfRows = notesInStack / EXPAND_COL_SIZE;
    if (notesInStack % EXPAND_COL_SIZE != 0 ) numberOfRows++;
    
    //get a single note size from the main note in stack
    NoteView * dummyNote = ((NoteView *)[stack.views lastObject]);
    [dummyNote resetSize];
    float noteWidth = dummyNote.bounds.size.width ;
    float noteHeight = dummyNote.bounds.size.height ;
    
    //calculate the rectangle size before adding seperators
    int rowItems = notesInStack >= EXPAND_COL_SIZE ? EXPAND_COL_SIZE : notesInStack;
    float seperatorSpace = MAX(noteWidth,noteHeight) * SEPERATOR_RATIO;
    float rectWidth = noteWidth + ( (noteWidth/3) * (rowItems - 1)) + ((numberOfRows) * seperatorSpace);
    float rectHeight= (2* seperatorSpace) + noteHeight + ( (noteHeight/3) * (numberOfRows - 1));
    
    return CGSizeMake(rectWidth, rectHeight);
}

-(CGRect) findFittingRectangle: (StackView *) stack
                        inView:(UIView *) collectionView{
    
    //find the size
    CGSize rectSize = [self getRectSizeForStack:stack
                               inCollectionView:collectionView];
    
    //now find the starting position
    float stackMiddleX = stack.frame.origin.x + stack.frame.size.width/2;
    float stackMiddleY = stack.frame.origin.y + stack.frame.size.height/2;
    
    //first find the starting x
    float startX = 0;
    float startY = 0;
    if (stackMiddleX + rectSize.width/2 > collectionView.bounds.origin.x + collectionView.bounds.size.width){
        //rect goes out of the right side of screen so fit it in a way that the right side of rect is on the right side of 
        //the screen
        startX = (collectionView.bounds.origin.x + collectionView.bounds.size.width) - rectSize.width;
    }
    else if (stackMiddleX - rectSize.width/2 < collectionView.bounds.origin.x){
        //rect goes out of the left side of screen so fit it in a way that the left side of rect is on the left side of 
        //the screen
        startX = collectionView.bounds.origin.x;
    }
    else{
        //rect fits around the stack 
        startX = stackMiddleX - rectSize.width/2;
    }
    
    //do the same thing to find starting y
    if (stackMiddleY + rectSize.height/2 > collectionView.bounds.origin.y + collectionView.bounds.size.height){
        startY  = (collectionView.bounds.origin.y + collectionView.bounds.size.height) - rectSize.height;
    }
    else if (stackMiddleY - rectSize.height/2 < collectionView.bounds.origin.y){
        startY = collectionView.bounds.origin.y;
    }
    else {
        startY = stackMiddleY - rectSize.height/2;
    }
    
    return CGRectMake(startX, startY, rectSize.width, rectSize.height);
}

-(NSArray *) checkForOverlapWithView: (UIView *) senderView
                    inCollectionView: (UIView *) collectionView{
    NSMutableArray * ans = [[NSMutableArray alloc] init];
    for (UIView * view in collectionView.subviews){
        if (view != senderView &&
            [view conformsToProtocol:@protocol(BulletinBoardObject)]){
            if ([self doesView:view OverlapWithView:senderView]){
                [ans addObject:view];
                
            }
        }
    }
    [ans addObject:senderView];
    return ans;
}
@end
