//
//  IdeaStockViewController.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DropboxDataModel.h"
#import "DropBoxAssociativeBulletinBoard.h"

@interface IdeaStockViewController : UIViewController <DBRestClientDelegate>
    
@property (nonatomic,strong) DropBoxAssociativeBulletinBoard * board;

@end
