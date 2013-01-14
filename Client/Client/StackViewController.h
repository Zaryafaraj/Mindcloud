//
//  StackViewController.h
//  IdeaStock
//
//  Created by Ali Fathalian on 5/17/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BulletinBoardObject.h"
#import "NoteViewDelegate.h"
#import "StackView.h"

@protocol StackViewDelegate;

@interface StackViewController : UIViewController <NoteViewDelegate>

@property (weak,nonatomic) NSMutableArray * notes;
@property (weak, nonatomic) id<StackViewDelegate,NoteViewDelegate>  delegate;
@property (weak,nonatomic) StackView * openStack;

@end

/*-----------------------------------------------------------
                        Delegates
 -----------------------------------------------------------*/

@protocol StackViewDelegate

- (void)returnedstackViewController: (StackViewController *) sender;

- (void)unstackItem : (UIView *) item 
            fromView: (UIView *) stackView 
       withPastCount: (int) count;


@end