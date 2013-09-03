//
//  NotificationContainer.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NotificationContainer.h"

@interface NotificationContainer()
@property (nonatomic, strong) NSMutableArray * updateAssociationNotifications;
@property (nonatomic, strong) NSMutableArray * deleteAssociationNotifications;
@property (nonatomic, strong) NSMutableArray * addAssociationNotifications;

@property (nonatomic, strong) NSMutableArray * addFragmentNamespaceElementNotifications;
@property (nonatomic, strong) NSMutableArray * deleteFragmentNamespaceElementNotifications;
@property (nonatomic, strong) NSMutableArray * updateFragmentNamespaceElementNotifications;

@property (nonatomic, strong) NSMutableArray * addFragmentNamespaceSubElementNotifications;
@property (nonatomic, strong) NSMutableArray * deleteFragmentNamespaceSubElementNotifications;
@property (nonatomic, strong) NSMutableArray * updateFragmentNamespaceSubElementNotifications;

@end
@implementation NotificationContainer

-(id) init
{
    self = [super init];
    self.updateAssociationNotifications = [NSMutableArray array];
    self.deleteAssociationNotifications = [NSMutableArray array];
    self.addAssociationNotifications = [NSMutableArray array];
    
    self.addFragmentNamespaceElementNotifications = [NSMutableArray array];
    self.updateFragmentNamespaceElementNotifications = [NSMutableArray array];
    self.deleteFragmentNamespaceElementNotifications = [NSMutableArray array];
    
    self.addFragmentNamespaceSubElementNotifications = [NSMutableArray array];
    self.updateFragmentNamespaceSubElementNotifications = [NSMutableArray array];
    self.deleteFragmentNamespaceSubElementNotifications = [NSMutableArray array];
    
    return self;
}

-(NSArray *) getUpdateAssociationNotifications
{
    return [self.updateAssociationNotifications copy];
}

-(NSArray *) getDeleteAssociationNotifications
{
    return [self.deleteAssociationNotifications copy];
}

-(NSArray *) getAddAssociationNotifications
{
    return [self.addAssociationNotifications copy];
}

-(void) addUpdateAssociationNotification:(UpdateAssociationNotification *)notification
{
    [self.updateAssociationNotifications addObject:notification];
}

-(void) addDeleteAssociationNotification:(DeleteAssociationNotification *)notificatoin
{
    [self.deleteAssociationNotifications addObject:notificatoin];
}

-(void) addAddAssociationNotification:(AddAssociationNotification *)notification
{
    [self.addAssociationNotifications addObject:notification];
}

/*! array of AddFragmentNamespaceNotification objects*/
-(NSArray *) getAddFragmentNamespaceElementNotifications
{
    return [self.addFragmentNamespaceElementNotifications copy];
}

/*! array of UpdateFragmentNamespaceElement objects*/
-(NSArray *) getUpdateFragmentNamespaceElementNotifications
{
    return [self.updateFragmentNamespaceElementNotifications copy];
}

/*! array of UpdateFragmentNamespaceElement objects*/
-(NSArray *) getDeleteFragmentNamespaceElementNotifications
{
    return [self.deleteFragmentNamespaceElementNotifications copy];
}

-(void) addAddFragmentNamespaceElementNotification:(AddFragmentNamespaceElementNotification *) notification
{
    [self.addFragmentNamespaceElementNotifications addObject:notification];
}

-(void) addUpdateFragmentNamespaceElementNotification:(UpdateFragmentNamespaceElementNotification *) notification
{
    [self.updateFragmentNamespaceElementNotifications addObject:notification];
}

-(void) addDeleteFragmentNamespaceElementNotification:(DeleteFragmentNamespaceElementNotification *) notification
{
    [self.deleteFragmentNamespaceElementNotifications addObject:notification];
}


/*! array of AddFragmentNamespaceSubElementNotification objects*/
-(NSArray *) getAddFragmentNamespaceSubElementNotifications
{
    return [self.addFragmentNamespaceSubElementNotifications copy];
}

/*! array of UpdateFragmentNamespaceSubElementNotification objects*/
-(NSArray *) getUpdateFragmentNamespaceSubElementNotifications
{
    return [self.updateFragmentNamespaceSubElementNotifications copy];
}

/*! array of DeleteFragmentNamespaceSubElementNotification objects*/
-(NSArray *) getDeleteFragmentNamespaceSubElementNotifications
{
    return [self.deleteFragmentNamespaceSubElementNotifications copy];
}

-(void) addAddFragmentNamespaceSubElementNotification:(AddFragmentNamespaceSubElementNotification *) notification
{
    [self.addFragmentNamespaceSubElementNotifications addObject:notification];
}

-(void) addUpdateFragmentNamespaceSubElementNotification:(UpdateFragmentNamespaceSubElementNotification *) notification
{
    [self.updateFragmentNamespaceSubElementNotifications addObject:notification];
}

-(void) addDeleteFragmentNamespaceSubElementNotification:(DeleteFragmentNamespaceSubElementNotification *) notification
{
    [self.deleteFragmentNamespaceSubElementNotifications addObject:notification];
}

-(void) clear
{
    [self.addAssociationNotifications removeAllObjects];
    [self.updateAssociationNotifications removeAllObjects];
    [self.deleteAssociationNotifications removeAllObjects];
    
    [self.addFragmentNamespaceElementNotifications removeAllObjects];
    [self.updateFragmentNamespaceElementNotifications removeAllObjects];
    [self.deleteFragmentNamespaceElementNotifications removeAllObjects];
    
    [self.addFragmentNamespaceSubElementNotifications removeAllObjects];
    [self.updateFragmentNamespaceSubElementNotifications removeAllObjects];
    [self.deleteFragmentNamespaceSubElementNotifications removeAllObjects];
}

@end
