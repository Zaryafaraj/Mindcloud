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
    [self.paintView startDrawing];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
