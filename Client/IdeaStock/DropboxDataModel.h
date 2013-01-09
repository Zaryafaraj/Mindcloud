//
//  DropboxDataModel.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionDataSource.h"
#import <DropboxSDK/DropboxSDK.h>
#import "CallBackDataModel.h"
#import "DropboxActionController.h"
#import "QueueProducer.h"

@interface DropboxDataModel : NSObject <CollectionDataSource,CallBackDataModel,DBRestClientDelegate> 


//action keyed on the action type
@property (nonatomic,strong) NSMutableDictionary * actions;


@property  (nonatomic, strong) DBRestClient *restClient;

/*
 This class is an implementation of the data model. 
 The main feature of this class is that it provides asynch communication with 
 the storage in this case Dropbox. 
 The results are returned via callbacks to the delegate of this method. 
 
 The previous methods getAllBulletinBoardsFromRoot, getBulletinBoard: and getNoteFroTheBulletinBoardAsynch are overrided to return nil and use the 
 callback mechanism to return their answers. These methods always return nil 
 
 It is important not to have synchronous communication with this class and only use 
 callbacks.
 */

//TODO I am not sure whether this is really an implementation of the DataModel protocol
//because it is somehow changing its behavior . 


/*
 This makes sure that no two tasks that can interfere , interfere with each other.
 */
@property (nonatomic,strong) id<DropboxActionController> actionController;

-(void) getAllBulletinBoardsAsynch;

/*
 This method asynchronously gets the bulletinBoard specified by bulletinBoardName. 
 It assumes that the bulletinBoardName is a valid existing bulletinBoard in the dropbox
 root.
 */
-(void) getBulletinBoardAsynch: (NSString *) bulletinBoardName;


@end
