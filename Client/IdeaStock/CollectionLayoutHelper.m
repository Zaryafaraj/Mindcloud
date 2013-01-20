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

+(void) adjustNotePositionsForX:(float *) positionX
                           andY:(float *) positionY
                         inView:(UIView *) collectionView
{
    
        float maxWidth = collectionView.frame.origin.x + collectionView.frame.size.width;
        float maxHeight = collectionView.frame.origin.y + collectionView.frame.size.height;
    
        if ( *positionX + NOTE_WIDTH > maxWidth ){
            *positionX = collectionView.frame.origin.x + collectionView.frame.size.width - NOTE_WIDTH;
        }
        if ( *positionY + NOTE_HEIGHT> maxHeight){
            *positionY = collectionView.frame.origin.x + collectionView.frame.size.height - NOTE_HEIGHT;
        }
        if (*positionX <  collectionView.frame.origin.x){
            *positionX = collectionView.frame.origin.x;
        }
        if (*positionY < collectionView.frame.origin.y){
            *positionY = collectionView.frame.origin.y;
        }
}

+(BOOL) doesView: (UIView *) view1
 OverlapWithView: (UIView *) view2
{
    
    CGPoint view1Center = CGPointMake(view1.frame.origin.x + (view1.frame.size.width/2), 
                                        view1.frame.origin.y + (view1.frame.size.height/2) );
    CGPoint view2Center = CGPointMake(view2.frame.origin.x + (view2.frame.size.width/2), 
                                      view2.frame.origin.y + (view2.frame.size.height/2) );
    
    CGFloat dx = view1Center.x - view2Center.x;
    CGFloat dy = view1Center.y - view2Center.y;
    
    float distance = sqrt(dx*dx + dy*dy);
    if ( distance < OVERLAP_RATIO * NOTE_WIDTH){
        return YES;
    }
    return NO;
}


+(UIView *) gatherNoteViewFor:(NSArray *) noteRefIDs
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


+(CGSize) getRectSizeForStack: (StackView *) stack
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

+(CGRect) findFittingRectangle: (StackView *) stack
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

+(NSArray *) checkForOverlapWithView: (UIView *) senderView
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

+ (CGRect) getStackingFrameForStackingWithTopView: (UIView *) mainView
{
    
    __block BOOL first = YES;
    
    CGRect stackFrame;
    if (first){
        if ([mainView isKindOfClass:[NoteView class]]){
            stackFrame = CGRectMake(mainView.frame.origin.x - ((STACKING_SCALING_WIDTH -1)/4) * mainView.frame.origin.x,
                                    mainView.frame.origin.y - ((STACKING_SCALING_HEIGHT -1)/4) * mainView.frame.origin.y,
                                    mainView.bounds.size.width * STACKING_SCALING_WIDTH,
                                    mainView.bounds.size.height * STACKING_SCALING_HEIGHT );
        }
        else if ([mainView isKindOfClass:[StackView class]]){
            stackFrame = mainView.frame;
        }
    }
    return stackFrame;
}

+(void) clearRectangle:(CGRect) rect
      inCollectionView:(UIView *)collectionView
  withMoveNoteFunction:(update_note_location_function) updateNote
{
    for (UIView * subView in collectionView.subviews){
        if ([subView conformsToProtocol:@protocol(BulletinBoardObject)]){
            if (CGRectIntersectsRect(subView.frame, rect)){
                
                float newStartX = subView.frame.origin.x;
                float newStartY = subView.frame.origin.y;
                
                float offsetX = EXIT_OFFSET_RATIO * subView.frame.size.width;
                float offsetY = EXIT_OFFSET_RATIO * subView.frame.size.height;
                
                //find the closest point for the view to exit
                float rectMid = rect.origin.x + rect.size.width/2;
                if (subView.frame.origin.x < rectMid){
                    //view is in the left side of the rect 
                    //find the distance to move the view come out of the rect
                    //it will first try to see if the view fits the screen if it exits from the right side rect
                    //if this is not possible it tries the lower side of the rect and if that doesnt work either
                    //it should definetly fit the top side ( given that the rect is not bigger than the screen)
                    //we try each case in order
                    
                    //first the left side. This distance is the distance between the left edge of the rect and the right edge of view
                    float distanceToExitX = (subView.frame.origin.x + subView.frame.size.width + offsetX) - rect.origin.x;
                    
                    //check to see if traveling this distance makes the subView fall out of screen on the left side
                    if ( subView.frame.origin.x - distanceToExitX > collectionView.bounds.origin.x){
                        //the view doesn't fall out of the screen so move make its starting point there 
                        newStartX = subView.frame.origin.x - distanceToExitX;
                    }
                    else{
                        //the view falls out of the screen if we move left, try moving down
                        //the distance is between the top edge of the subview and low buttom of the rect
                        float distanceToExitY = (rect.origin.y + rect.size.height + offsetY) - (subView.frame.origin.y);
                        if (subView.frame.origin.y + subView.frame.size.height +distanceToExitY < collectionView.bounds.origin.y + collectionView.bounds.size.height){
                            //the view can be fit outside the lower edge of the rect
                            newStartY = subView.frame.origin.y + distanceToExitY;
                        }
                        else {
                            //the view cannot be fit in the left side of rect or the down side of the rect, surely it can fit in the upper side of the rect
                            //find the distance to exit from the top side. the distance is between the low edge of the view and the top edge of the rect
                            distanceToExitY = (subView.frame.origin.y + subView.frame.size.height + offsetY) - rect.origin.y;
                            newStartY = subView.frame.origin.y - distanceToExitY;
                        }
                    }
                    
                }
                
                
                //we follow the same algorithm if the view is in the right side of the rect
                else {
                    
                    //try the rightside. The distance is between the right edge of rect and left edge of view
                    float distanceToExitX = (rect.origin.x + rect.size.width + offsetX) - (subView.frame.origin.x );
                    if (subView.frame.origin.x + subView.frame.size.width + distanceToExitX < collectionView.bounds.origin.x + collectionView.bounds.size.width){
                        //fits in the right side 
                        newStartX = subView.frame.origin.x + distanceToExitX;
                    }
                    else{
                        //try the lower side
                        float distanceToExitY = (rect.origin.y + rect.size.height + offsetY) - (subView.frame.origin.y);
                        if (subView.frame.origin.y +subView.frame.size.height + distanceToExitY < collectionView.bounds.origin.y + collectionView.bounds.size.height){
                            newStartY = subView.frame.origin.y + distanceToExitY;
                        }
                        else{
                            //use the top side
                            distanceToExitY = (subView.frame.origin.y + subView.frame.size.height + offsetY) - rect.origin.y;
                            newStartY = subView.frame.origin.y - distanceToExitY;
                        }
                    }
                }
                
                [UIView animateWithDuration:0.25 animations:^{subView.frame = CGRectMake(newStartX, newStartY, subView.frame.size.width, subView.frame.size.height);}];
                if ([subView isKindOfClass:[NoteView class]]){
                    updateNote((NoteView *) subView);
                }
                else if ([subView isKindOfClass:[StackView class]]){
                    StackView * stack = (StackView *) subView;
                    for(NoteView * stackNoteView in stack.views){
                        stackNoteView.frame = stack.frame;
                        updateNote(stackNoteView);
                    }
                }
            }
        }
    }
}

+(void) expandNotes:(NSArray *) items
             inRect:(CGRect) rect
withMoveNoteFunction:(update_note_location_function) updateNote
{
    
    [((NoteView *) [items lastObject]) resetSize];
    float noteWidth = ((NoteView *)[items lastObject]).frame.size.width  ;
    float noteHeight = ((NoteView *)[items lastObject]).frame.size.height;
    float seperator = SEPERATOR_RATIO * MAX(noteWidth, noteHeight);
    
    float startX = rect.origin.x + seperator;
    float startY = rect.origin.y + seperator;
    
    int rowCount = 0;
    int colCount = 0;
    for (NoteView * view in items){
        CGRect noteRect = CGRectMake(startX, startY, view.frame.size.width, view.frame.size.height);
        [CollectionAnimationHelper animateExpandNote: view InRect:noteRect];
        rowCount++;
        if (rowCount >= EXPAND_COL_SIZE){
            rowCount = 0;
            colCount++;
            startX = rect.origin.x + seperator * (colCount+1);
            startY += noteHeight/3;
        }
        else{
            startX += noteWidth/3;
        }
        updateNote(view);
    }
}

+(void) layoutViewsForOrientationChange:(UIView *) collectionView
{
    
    for (UIView * view in collectionView.subviews){
        
        float positionX = view.frame.origin.x;
        float positionY = view.frame.origin.y;
        BOOL changed = NO;
        if ( positionX + view.frame.size.width > collectionView.frame.origin.x + collectionView.frame.size.width ){
            positionX = collectionView.frame.origin.x + collectionView.frame.size.width - NOTE_WIDTH;
            changed = YES;
        }
        if ( positionY + view.frame.size.height > collectionView.frame.origin.x + collectionView.frame.size.height){
            positionY = collectionView.frame.origin.x + collectionView.frame.size.height - NOTE_HEIGHT;
            changed = YES;
        }
        if (positionX <  collectionView.frame.origin.x){
            positionX = collectionView.frame.origin.x;
            changed = YES;
        }
        if (positionY < collectionView.frame.origin.y){
            positionY = collectionView.frame.origin.y;
            changed = YES;
        }
        
        if(changed){
            view.frame = CGRectMake(positionX, positionY, view.frame.size.width, view.frame.size.height);
        }
    }
}

+(CGRect) getFrameForNewNote:(UIView *) view
                AddedToPoint: (CGPoint) location
                        InCollectionView:(UIView *) collectionView
{
    
    CGRect frame = CGRectMake(location.x, location.y, NOTE_WIDTH, NOTE_HEIGHT);
    
    
    BOOL frameChanged = NO;
    CGFloat newOriginX = frame.origin.x;
    CGFloat newOriginY = frame.origin.y;
    
    
    if (frame.origin.x < collectionView.frame.origin.x){
        frameChanged = YES;
        newOriginX = collectionView.frame.origin.x;
    }
    if (frame.origin.y < collectionView.frame.origin.y){
        frameChanged = YES;
        newOriginY = collectionView.frame.origin.y;
    }
    if (frame.origin.x + frame.size.width > 
        collectionView.frame.origin.x + collectionView.frame.size.width){
        frameChanged = YES;
        newOriginX = collectionView.frame.origin.x + collectionView.frame.size.width - frame.size.width;
    }
    if (frame.origin.y + frame.size.height > 
        collectionView.frame.origin.y + collectionView.frame.size.height){
        frameChanged = YES;
        newOriginY = collectionView.frame.origin.y + collectionView.frame.size.height - frame.size.height - 50;
    }
    
    if (view.frame.origin.x + view.frame.size.width >
        collectionView.frame.origin.x + collectionView.frame.size.width){
        frameChanged = YES;
        newOriginX = collectionView.frame.origin.x + collectionView.frame.size.width - view.frame.size.width;
    }
    if (view.frame.origin.y + view.frame.size.height >
        collectionView.frame.origin.y + collectionView.frame.size.height){
        frameChanged = YES;
        newOriginY = collectionView.frame.origin.y + collectionView.frame.size.height - view.frame.size.height - 50;
    }
    if (frameChanged){
            frame = CGRectMake(newOriginX, newOriginY,frame.size.width, frame.size.height);

    }
    return frame;
}

+(void) updateViewLocationForView:(UIView *) view
                 inCollectionView:(UIView *) collectionView
{
    
        BOOL frameChanged = NO;
        CGFloat newOriginX = view.frame.origin.x;
        CGFloat newOriginY = view.frame.origin.y;
    
        if (view.frame.origin.x < collectionView.frame.origin.x){
            frameChanged = YES;
            newOriginX = collectionView.frame.origin.x;
        }
        if (view.frame.origin.y < collectionView.frame.origin.y){
            frameChanged = YES;
            newOriginY = collectionView.frame.origin.y;
        }
        if (view.frame.origin.x + view.frame.size.width > 
            collectionView.frame.origin.x + collectionView.frame.size.width){
            frameChanged = YES;
            newOriginX = collectionView.frame.origin.x + collectionView.frame.size.width - view.frame.size.width;
        }
        if (view.frame.origin.y + view.frame.size.height > 
            collectionView.frame.origin.y + collectionView.frame.size.height){
            frameChanged = YES;
            newOriginY = collectionView.frame.origin.y + collectionView.frame.size.height - view.frame.size.height - 50;
        }
        
        if (frameChanged){
            CGRect newFrame = CGRectMake(newOriginX, newOriginY, view.frame.size.width, view.frame.size.height);
            [CollectionAnimationHelper animateMoveNote:view
                            backIntoScreenBoundsInRect:newFrame];
        }
}
@end
