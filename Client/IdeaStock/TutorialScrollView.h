//
//  TutorialScrollView.h
//  Mindcloud
//
//  Created by Ali Fathalian on 12/16/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialPaintView.h"

@interface TutorialScrollView : UIScrollView <TutorialPaintViewDelegate>

@property (nonatomic, strong) TutorialPaintView * paintView;
@property (nonatomic, assign) int  stopPoint;

-(void) displayContent:(BOOL) animated;

@end
