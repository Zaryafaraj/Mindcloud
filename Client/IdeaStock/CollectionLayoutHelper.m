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
#import "PaintControlView.h"

@interface CollectionLayoutHelper()

@property float noteWidth;
@property float noteHeight;

@end
@implementation CollectionLayoutHelper

+(void) adjustNotePositionsForX:(float *) positionXCenter
                           andY:(float *) positionYCenter
                         inView:(UIView *) collectionView
{
    
        float maxWidth = collectionView.bounds.origin.x + collectionView.bounds.size.width;
        float maxHeight = collectionView.bounds.origin.y + collectionView.bounds.size.height;
    
        if ( *positionXCenter  > maxWidth ){
            *positionXCenter = collectionView.bounds.origin.x + collectionView.bounds.size.width - NOTE_WIDTH/2;
        }
        if ( *positionYCenter > maxHeight){
            *positionYCenter = collectionView.bounds.origin.x + collectionView.bounds.size.height - NOTE_HEIGHT/2;
        }
        if (*positionXCenter - NOTE_WIDTH/2 <  collectionView.bounds.origin.x){
            *positionXCenter = collectionView.bounds.origin.x;
        }
        if (*positionYCenter - NOTE_HEIGHT/2 < collectionView.bounds.origin.y){
            *positionYCenter = collectionView.bounds.origin.y;
        }
}

+(BOOL) doesView: (UIView *) view1
 OverlapWithView: (UIView *) view2
{
    
    CGPoint view1Center = view1.center;
    CGPoint view2Center = view2.center;
    
    CGFloat dx = view1Center.x - view2Center.x;
    CGFloat dy = view1Center.y - view2Center.y;
    
    float distance = sqrt(dx*dx + dy*dy);
    if ( distance < OVERLAP_RATIO * NOTE_WIDTH){
        return YES;
    }
    return NO;
}


+(CGRect) findFittingRectangle: (StackView *) stack
                        inView:(UIView *) collectionView{
    
    //find the size
    CGSize rectSize = [self getRectSizeForStack:stack
                               inCollectionView:collectionView];
    
    //now find the starting position
    float stackMiddleX = stack.center.x;
    float stackMiddleY = stack.center.y;
    
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

+(CGSize) getRectSizeForStack: (StackView *) stack
             inCollectionView:(UIView *) collectionView{
    
    int notesInStack = [stack.views count];
    
    //get the number of rows in expanded state
    int numberOfRows = notesInStack / EXPAND_COL_SIZE;
    if (notesInStack % EXPAND_COL_SIZE != 0 ) numberOfRows++;
    
    //get a single note size from the main note in stack
    float noteWidth = stack.bounds.size.width ;
    float noteHeight = stack.bounds.size.height ;
    
    //calculate the rectangle size before adding seperators
    int rowItems = notesInStack >= EXPAND_COL_SIZE ? EXPAND_COL_SIZE : notesInStack;
    float seperatorSpace = MAX(noteWidth,noteHeight) * SEPERATOR_RATIO;
    float rectWidth = noteWidth + ( (noteWidth/3) * (rowItems - 1)) + ((numberOfRows) * seperatorSpace);
    float rectHeight= (2* seperatorSpace) + noteHeight + ( (noteHeight/3) * (numberOfRows - 1));
    
    return CGSizeMake(rectWidth, rectHeight);
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
    
    CGRect frame = CGRectMake( mainView.center.x - STACK_WIDTH/2,
                              mainView.center.y - STACK_HEIGHT/2,
                              STACK_WIDTH,
                              STACK_HEIGHT);
    return frame;
}

+(void) clearRectangle:(CGRect) rect
      inCollectionView:(UIView *)collectionView
  withMoveNoteFunction:(update_note_location_function) updateNote
{
    for (UIView * subView in collectionView.subviews){
        if ([subView conformsToProtocol:@protocol(BulletinBoardObject)]){
            CGRect viewBounds = CGRectMake(subView.center.x - subView.bounds.size.width/2,
                                           subView.center.y - subView.bounds.size.height/2,
                                           subView.bounds.size.width,
                                           subView.bounds.size.height);
            if (CGRectIntersectsRect(viewBounds, rect)){
                
                float newStartX = subView.center.x;
                float newStartY = subView.center.y;
                
                float offsetX = EXIT_OFFSET_RATIO * subView.bounds.size.width;
                float offsetY = EXIT_OFFSET_RATIO * subView.bounds.size.height;
                
                //find the closest point for the view to exit
                float rectMid = rect.origin.x + rect.size.width/2;
                if (viewBounds.origin.x < rectMid){
                    //view is in the left side of the rect
                    //find the distance to move the view come out of the rect
                    //it will first try to see if the view fits the screen if it exits from the right side rect
                    //if this is not possible it tries the lower side of the rect and if that doesnt work either
                    //it should definetly fit the top side ( given that the rect is not bigger than the screen)
                    //we try each case in order
                    
                    //first the left side. This distance is the distance between the left edge of the rect and the right edge of view
                    float distanceToExitX = (viewBounds.origin.x + subView.bounds.size.width + offsetX) - rect.origin.x;
                    
                    //check to see if traveling this distance makes the subView fall out of screen on the left side
                    if ( viewBounds.origin.x - distanceToExitX > collectionView.bounds.origin.x){
                        //the view doesn't fall out of the screen so move make its starting point there
                        newStartX = viewBounds.origin.x - distanceToExitX;
                    }
                    else{
                        //the view falls out of the screen if we move left, try moving down
                        //the distance is between the top edge of the subview and low buttom of the rect
                        float distanceToExitY = (rect.origin.y + rect.size.height + offsetY) - (viewBounds.origin.y);
                        if (viewBounds.origin.y + viewBounds.size.height +distanceToExitY < collectionView.bounds.origin.y + collectionView.bounds.size.height){
                            //the view can be fit outside the lower edge of the rect
                            newStartY = viewBounds.origin.y + distanceToExitY;
                        }
                        else {
                            //the view cannot be fit in the left side of rect or the down side of the rect, surely it can fit in the upper side of the rect
                            //find the distance to exit from the top side. the distance is between the low edge of the view and the top edge of the rect
                            distanceToExitY = (viewBounds.origin.y + viewBounds.size.height + offsetY) - rect.origin.y;
                            newStartY = viewBounds.origin.y - distanceToExitY;
                        }
                    }
                    
                }
                
                
                //we follow the same algorithm if the view is in the right side of the rect
                else {
                    
                    //try the rightside. The distance is between the right edge of rect and left edge of view
                    float distanceToExitX = (rect.origin.x + rect.size.width + offsetX) - (viewBounds.origin.x );
                    if (viewBounds.origin.x + viewBounds.size.width + distanceToExitX < collectionView.bounds.origin.x + collectionView.bounds.size.width){
                        //fits in the right side
                        newStartX = viewBounds.origin.x + distanceToExitX;
                    }
                    else{
                        //try the lower side
                        float distanceToExitY = (rect.origin.y + rect.size.height + offsetY) - (viewBounds.origin.y);
                        if (viewBounds.origin.y + viewBounds.size.height + distanceToExitY < collectionView.bounds.origin.y + collectionView.bounds.size.height){
                            newStartY = viewBounds.origin.y + distanceToExitY;
                        }
                        else{
                            //use the top side
                            distanceToExitY = (viewBounds.origin.y + viewBounds.size.height + offsetY) - rect.origin.y;
                            newStartY = viewBounds.origin.y - distanceToExitY;
                        }
                    }
                }
                CGRect frame = CGRectMake(newStartX, newStartY, viewBounds.size.width, viewBounds.size.height);
                [CollectionAnimationHelper animateMoveNoteOutOfExpansion:subView
                                                                 toFrame:frame];
                if ([subView isKindOfClass:[NoteView class]]){
                    updateNote((NoteView *) subView);
                }
                else if ([subView isKindOfClass:[StackView class]]){
                    StackView * stack = (StackView *) subView;
                    for(NoteView * stackNoteView in stack.views){
                        stackNoteView.center = stack.center;
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
    
    float noteWidth = ((NoteView *)[items lastObject]).bounds.size.width  ;
    float noteHeight = ((NoteView *)[items lastObject]).bounds.size.height;
    float seperator = SEPERATOR_RATIO * MAX(noteWidth, noteHeight);
    
    float startX = rect.origin.x + seperator;
    float startY = rect.origin.y + seperator;
    
    int rowCount = 0;
    int colCount = 0;
    for (NoteView * view in items){
        CGRect noteRect = CGRectMake(startX, startY, view.bounds.size.width, view.bounds.size.height);
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
        if ([view isKindOfClass:[NoteView class]] || [view isKindOfClass:[StackView class]])
        {
            
            float positionXCenter = view.center.x;
            float positionYCenter = view.center.y;
            BOOL changed = NO;
            if ( positionXCenter + view.bounds.size.width/2 > collectionView.bounds.origin.x + collectionView.bounds.size.width ){
                positionXCenter = collectionView.bounds.origin.x + collectionView.bounds.size.width - NOTE_WIDTH;
                changed = YES;
            }
            if ( positionYCenter + view.bounds.size.height > collectionView.bounds.origin.x + collectionView.bounds.size.height){
                positionYCenter = collectionView.bounds.origin.x + collectionView.bounds.size.height - NOTE_HEIGHT;
                changed = YES;
            }
            if (positionXCenter - view.bounds.size.width/2 <  collectionView.bounds.origin.x){
                positionXCenter = collectionView.bounds.origin.x;
                changed = YES;
            }
            if (positionYCenter - view.bounds.size.width/2 < collectionView.bounds.origin.y){
                positionYCenter = collectionView.bounds.origin.y;
                changed = YES;
            }
            
            if(changed){
                view.center = CGPointMake(positionXCenter, positionYCenter);
                
            }
        }
    }
}

+(CGRect) adjustFrame:(CGRect) originalFrame
              forView: (UIView *) view
      forBoundsOfView:(UIView *) collectionView
{
    BOOL frameChanged = NO;
    CGFloat newOriginX = originalFrame.origin.x;
    CGFloat newOriginY = originalFrame.origin.y;
    
    
    if (originalFrame.origin.x < collectionView.bounds.origin.x){
        frameChanged = YES;
        newOriginX = collectionView.bounds.origin.x;
    }
    if (originalFrame.origin.y < collectionView.bounds.origin.y){
        frameChanged = YES;
        newOriginY = collectionView.bounds.origin.y;
    }
    if (originalFrame.origin.x + originalFrame.size.width >
        collectionView.bounds.origin.x + collectionView.bounds.size.width){
        frameChanged = YES;
        newOriginX = collectionView.bounds.origin.x + collectionView.bounds.size.width - originalFrame.size.width;
    }
    if (originalFrame.origin.y + originalFrame.size.height >
        collectionView.bounds.origin.y + collectionView.bounds.size.height){
        frameChanged = YES;
        newOriginY = collectionView.bounds.origin.y + collectionView.bounds.size.height - originalFrame.size.height - 50;
    }
    
    if (view.center.x + view.bounds.size.width/2 >
        collectionView.bounds.origin.x + collectionView.bounds.size.width){
        frameChanged = YES;
        newOriginX = collectionView.bounds.origin.x + collectionView.bounds.size.width - view.bounds.size.width;
    }
    if (view.center.y + view.bounds.size.height/2 >
        collectionView.bounds.origin.y + collectionView.bounds.size.height){
        frameChanged = YES;
        newOriginY = collectionView.bounds.origin.y + collectionView.bounds.size.height - view.bounds.size.height - 50;
    }
    if (frameChanged){
        originalFrame = CGRectMake(newOriginX, newOriginY,originalFrame.size.width, originalFrame.size.height);
        
    }
    return originalFrame;
    
}
+(CGRect) getFrameForNewNote:(UIView *) view
                AddedToPoint: (CGPoint) location
            InCollectionView:(UIView *) collectionView
{
    
    CGRect frame = CGRectMake(location.x - NOTE_WIDTH/2,
                              location.y - NOTE_HEIGHT/2,
                              NOTE_WIDTH,
                              NOTE_HEIGHT);
    return [self adjustFrame:frame forView:view forBoundsOfView:collectionView];
    
    
}

+(void) updateViewLocationForView:(UIView *) view
                 inCollectionView:(UIView *) collectionView
{
    
    BOOL frameChanged = NO;
    CGFloat newOriginX = view.frame.origin.x;
    CGFloat newOriginY = view.frame.origin.y;
    
    if (view.frame.origin.x < collectionView.bounds.origin.x){
        frameChanged = YES;
        newOriginX = collectionView.bounds.origin.x;
    }
    if (view.frame.origin.y < collectionView.bounds.origin.y){
        frameChanged = YES;
        newOriginY = collectionView.bounds.origin.y;
    }
    if (view.frame.origin.x + view.frame.size.width >
        collectionView.bounds.origin.x + collectionView.bounds.size.width){
        frameChanged = YES;
        newOriginX = collectionView.bounds.origin.x + collectionView.bounds.size.width - view.bounds.size.width;
    }
    if (view.frame.origin.y + view.frame.size.height >
        collectionView.bounds.origin.y + collectionView.bounds.size.height){
        frameChanged = YES;
        newOriginY = collectionView.frame.origin.y + collectionView.bounds.size.height - view.bounds.size.height - 50;
    }
    
    if (frameChanged){
        CGRect newFrame = CGRectMake(newOriginX, newOriginY, view.frame.size.width, view.frame.size.height);
        [CollectionAnimationHelper animateMoveNote:view
                        backIntoScreenBoundsInRect:newFrame];
    }
}

+(void) removeNote:(NoteView *) noteItem
         fromStack:(StackView *) stack
  InCollectionView: (UIView *) collectionView withCountInStack:(int) count
       andCallback:(layout_unstack_finished)callback
{
    
    [noteItem resetSize];
    float offsetX = SEPERATOR_RATIO * noteItem.frame.size.width;
    float offsetY = SEPERATOR_RATIO * noteItem.frame.size.height;
    noteItem.frame = stack.frame;
    [collectionView addSubview:noteItem];
    CGRect finalRect = CGRectMake(stack.frame.origin.x + (count * offsetX),
                                  stack.frame.origin.y + (count * offsetY),
                                  noteItem.frame.size.width,
                                  noteItem.frame.size.height);
    [CollectionAnimationHelper animateUnstack:noteItem
                                    fromStack:stack
                                 inCollection:collectionView
                                withFinalRect:finalRect
                           withFinishCallback:callback];
}


+(void) moveView:(UIView *) view
inCollectionView:(UIView *) collectionView
     toNewCenter:(CGPoint) newCenter
{
    [CollectionAnimationHelper animateMoveView:view
                                    intoCenter:newCenter
                                  inCollection:collectionView];
}

+(void) moveView:(UIView *) view
inCollectionView:(UIView *) collectionView
     toNewCenter:(CGPoint) newCenter
  withCompletion:(move_noted_finished)callback
{
    [CollectionAnimationHelper animateMoveView:view intoCenter:newCenter
                                  inCollection:collectionView
                                withCompletion:^{
                                    callback();
                                }];
}
+(void) scaleView:(UIView *) view
 inCollectionView:(UIView *) collectionView
        withScale:(float) scale
{
    [CollectionAnimationHelper animateScaleView:view
                                      withScale:scale
                                   inCollection:collectionView];
}


@end
