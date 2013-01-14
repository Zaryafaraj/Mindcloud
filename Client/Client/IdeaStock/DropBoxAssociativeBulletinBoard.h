//
//  DropBoxAssociativeBulletinBoard.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/6/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "AssociativeBulletinBoard.h"
#import <DropboxSDK/DropboxSDK.h>
#import "CallBackDataModel.h"
#import "QueueProducer.h"
#import "DropboxActionController.h"

/*
 This class provides all the functionality of an associative bulletin board 
 with the extra functionality that it can also be used as a delegate for 
 responsing to the dropbox asynch calls
 */
@interface DropBoxAssociativeBulletinBoard : AssociativeBulletinBoard <DropboxActionController>

-(id) initBulletinBoardFromXoomlWithName:(NSString *)bulletinBoardName;

//initiates the bulletin board from the available data on the disk
//this can be used in offline mode with some support
- (void) initiateBulletinBoad;

//for stopping or starting the syncrhnozation timer
-(void) startTimer;

-(void) stopTimer;

-(void) cleanUp;
@end
