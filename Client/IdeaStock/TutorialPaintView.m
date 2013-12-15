//
//  TutorialPaintView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/12/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "TutorialPaintView.h"

@interface TutorialPaintView()
@property (nonatomic, strong) DrawingTraceContainer * container;
@end

@implementation TutorialPaintView


-(id) initWithContainer:(DrawingTraceContainer *) container
{
    self = [super init];
    if (self)
    {
        self.container = container;
    }
    return self;
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
