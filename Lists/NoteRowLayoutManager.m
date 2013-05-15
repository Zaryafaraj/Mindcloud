//
//  ListCenteredCollectionLayoutManager.m
//  Lists
//
//  Created by Ali Fathalian on 4/30/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "NoteRowLayoutManager.h"

@implementation NoteRowLayoutManager

- (CGRect) frameForOpenedRow:(CGRect) closedFrame
{
    return     CGRectMake(closedFrame.origin.x + closedFrame.size.width/9,
                          closedFrame.origin.y,
                          8*closedFrame.size.width/9,
                          closedFrame.size.height);
}


-(CGRect) frameForButtonInBounds:(CGRect) parentBounds
              WithBackgroundView:(UIView *) backgroundView
{
    CGSize buttonSize = CGSizeMake(parentBounds.size.width/9,
                                   parentBounds.size.height);
    CGRect addButtonFrame = CGRectMake(backgroundView.bounds.origin.x,
                                       backgroundView.bounds.origin.y,
                                       buttonSize.width,
                                       buttonSize.height);
    
    
    return addButtonFrame;
}

@end
