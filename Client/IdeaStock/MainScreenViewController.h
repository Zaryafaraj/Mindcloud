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

@interface MainScreenDropboxViewController : UIViewController <DropboxActionController>

//Maybe at some point I should make the dropbox datamodel follow 
//the singleton pattern but as for now I imagine there is one instance of 
//this for the main page and one instance per bulletinboard. This should make stuff easier. 
@property (strong, readonly) DropboxDataModel * dropBox;

@property (atomic) BOOL actionInProgress;
//maybe better to make this private
-(void) finishedWorkingWithBulletinBoard;

@end
