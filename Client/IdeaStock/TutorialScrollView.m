//
//  TutorialScrollView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/16/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "TutorialScrollView.h"

@implementation TutorialScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) displayContent:(BOOL) animated
{
    self.contentOffset = CGPointMake(self.contentOffset.x + 90, self.contentOffset.y + 60);
    self.paintView.stopPoint = 0;
    self.paintView.delegate = self;
    [self.paintView startDrawing];
}

#pragma mark paintViewDelegate
-(void) animationsStoppedAtIndex:(int)index
{
}

-(void) animationsFinished
{
    
}
@end
