//
//  CollectionViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScreenViewController.h"
#import "StackViewController.h"
#import "NoteViewDelegate.h"
#import "MindcloudBoard.h"

@interface CollectionViewController : UIViewController <UIScrollViewDelegate,StackViewDelegate, NoteViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) NSString * bulletinBoardName;

@property (strong, nonatomic) MindcloudBoard * board;

@property (weak,nonatomic) MainScreenViewController * parent;



@end
