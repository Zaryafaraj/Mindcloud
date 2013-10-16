//
//  MainScreenDropbox.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/24/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesViewController.h"
#import "UIEditableTableViewDelegate.h"
#import "CategorizationViewDelegate.h"
#import "MindcloudAllCollectionsDelegate.h"

#define UNTITLED_COLLECTION_NAME @"Untitled"

@interface AllCollectionsViewController : UIViewController
<UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UICollectionViewDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UIEditableTableViewDelegate,
UIPopoverControllerDelegate,
CategorizationViewDelegate,
MindcloudAllCollectionsDelegate>

@property (atomic) BOOL actionInProgress;
@property (weak, nonatomic) CategoriesViewController * categoriesController;

-(void) finishedWorkingWithCollection:(NSString * ) collectionName;

-(void) thumbnailCreatedForCollectionName:(NSString *) collectionName
                                 withData:(NSData *) imgData;

-(void) renamedCollectionWithName:(NSString *) collectionName
              toNewCollectionName:(NSString *) newName;

@end
