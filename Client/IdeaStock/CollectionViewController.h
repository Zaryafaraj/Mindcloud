//
//  CollectionViewController.h
//  Mindcloud
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AllCollectionsViewController.h"
#import "StackViewController.h"
#import "NoteViewDelegate.h"
#import "MindcloudCollection.h"
#import "CollectionBoardDelegate.h"

@interface CollectionViewController : UIViewController<
UIScrollViewDelegate,
StackViewDelegate,
NoteViewDelegate,
CollectionBoardDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,
UIPopoverControllerDelegate>

@property (strong,nonatomic) NSString * bulletinBoardName;
@property (strong, nonatomic) MindcloudCollection * board;
@property (weak,nonatomic) AllCollectionsViewController * parent;

//because modal view does'nt provide this notification
-(void) applicationWillEnterForeground:(NSNotification *) notification;
-(void) applicationHasGoneInBackground:(NSNotification *) notification;

@end
