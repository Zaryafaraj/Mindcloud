//
//  NotificationContainer.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationContainer : NSObject

//aray of update note notification objects
-(NSArray *) getUpdateNoteNotifications;

//array of delete note notification objects
-(NSArray *) getDeleteNoteNotifications;

//array of add note notification objects
-(NSArray *) getAddNoteNotifications;

//array of add stacking notification objects
-(NSArray *) getAddStackingNotifications;

//array of update stacking notification objects
-(NSArray *) getUpdateStackingNotifications;

//array of delete stacking Notification objects
-(NSArray *) getDeleteStackingNotifications;

@end
