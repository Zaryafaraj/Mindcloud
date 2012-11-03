//
//  MainScreenDropbox.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/24/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropboxDataModel.h"
#import "QueueProducer.h"
#import "DropboxActionController.h"

@interface MainScreenViewController : UIViewController
<UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UICollectionViewDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
UITableViewDelegate>

@property (atomic) BOOL actionInProgress;
//maybe better to make this private
-(void) finishedWorkingWithBulletinBoard;

@end
