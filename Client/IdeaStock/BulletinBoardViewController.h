//
//  BulletinBoardViewController.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainScreenDropboxViewController.h"
#import "StackViewController.h"
#import "NoteViewDelegate.h"
#import "DropBoxAssociativeBulletinBoard.h"

@interface BulletinBoardViewController : UIViewController <UIScrollViewDelegate,StackViewDelegate, NoteViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) NSString * bulletinBoardName;

@property (strong, nonatomic) DropBoxAssociativeBulletinBoard * board;

@property (weak,nonatomic) MainScreenDropboxViewController * parent;



@end
