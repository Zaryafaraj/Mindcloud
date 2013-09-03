//
//  NotificationContainer.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UpdateAssociationNotification.h"
#import "DeleteAssociationNotification.h"
#import "AddAssociationNotification.h"
#import "AddFragmentNamespaceElementNotification.h"
#import "UpdateFragmentNamespaceElementNotification.h"
#import "DeleteFragmentNamespaceElementNotification.h"
#import "AddFragmentNamespaceSubElementNotification.h"
#import "DeleteFragmentNamespaceSubElementNotification.h"
#import "UpdateFragmentNamespaceSubElementNotification.h"

@interface NotificationContainer : NSObject

/*! aray of UpdateAssociationNotification objects*/
-(NSArray *) getUpdateAssociationNotifications;

/*! array of DelteAssociationNotification objects */
-(NSArray *) getDeleteAssociationNotifications;

/*! array of AddAssociationNotification objects*/
-(NSArray *) getAddAssociationNotifications;

-(void) addUpdateAssociationNotification: (UpdateAssociationNotification *) notification;

-(void) addDeleteAssociationNotification: (DeleteAssociationNotification *) notificatoin;

-(void) addAddAssociationNotification: (AddAssociationNotification *) notification;




/*! array of AddFragmentNamespaceNotification objects*/
-(NSArray *) getAddFragmentNamespaceElementNotifications;

/*! array of UpdateFragmentNamespaceElement objects*/
-(NSArray *) getUpdateFragmentNamespaceElementNotifications;

/*! array of UpdateFragmentNamespaceElement objects*/
-(NSArray *) getDeleteFragmentNamespaceElementNotifications;

-(void) addAddFragmentNamespaceElementNotification:(AddFragmentNamespaceElementNotification *) notification;

-(void) addUpdateFragmentNamespaceElementNotification:(UpdateFragmentNamespaceElementNotification *) notification;

-(void) addDeleteFragmentNamespaceElementNotification:(DeleteFragmentNamespaceElementNotification *) notification;



/*! array of AddFragmentNamespaceSubElementNotification objects*/
-(NSArray *) getAddFragmentNamespaceSubElementNotifications;

/*! array of UpdateFragmentNamespaceSubElementNotification objects*/
-(NSArray *) getUpdateFragmentNamespaceSubElementNotifications;

/*! array of DeleteFragmentNamespaceSubElementNotification objects*/
-(NSArray *) getDeleteFragmentNamespaceSubElementNotifications;

-(void) addAddFragmentNamespaceSubElementNotification:(AddFragmentNamespaceSubElementNotification *) notification;

-(void) addUpdateFragmentNamespaceSubElementNotification:(UpdateFragmentNamespaceSubElementNotification *) notification;

-(void) addDeleteFragmentNamespaceSubElementNotification:(DeleteFragmentNamespaceSubElementNotification *) notification;

-(void) clear;
@end
