//
//  NotificationContainer.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NotificationContainer.h"

@interface NotificationContainer()
@property (nonatomic, strong) NSMutableArray * updateNoteNotifications;
@property (nonatomic, strong) NSMutableArray * deleteNoteNotifications;
@property (nonatomic, strong) NSMutableArray * addNoteNotifications;
@property (nonatomic, strong) NSMutableArray * addStackingNotifications;
@property (nonatomic, strong) NSMutableArray * updateStackingNotifications;
@property (nonatomic, strong) NSMutableArray * deleteStackingNotifications;
@end
@implementation NotificationContainer

-(id) init
{
    self = [super init];
    self.updateNoteNotifications = [NSMutableArray array];
    self.deleteNoteNotifications = [NSMutableArray array];
    self.addNoteNotifications = [NSMutableArray array];
    self.addStackingNotifications = [NSMutableArray array];
    self.updateStackingNotifications = [NSMutableArray array];
    self.DeleteStackingNotifications = [NSMutableArray array];
    return self;
}

-(NSArray *) getUpdateNoteNotifications
{
    return [self.updateNoteNotifications copy];
}

-(NSArray *) getDeleteNoteNotifications
{
    return [self.deleteNoteNotifications copy];
}

-(NSArray *) getAddNoteNotifications
{
    return [self.addNoteNotifications copy];
}

-(NSArray *) getAddStackingNotifications
{
    return [self.addStackingNotifications copy];
}

-(NSArray *) getUpdateStackingNotifications
{
    return [self.updateStackingNotifications copy];
}

-(NSArray *) getDeleteStackingNotifications
{
    return [self.deleteStackingNotifications copy];
}

-(void) addUpdateNoteNotification:(UpdateNoteNotification *)notification
{
    [self.updateNoteNotifications addObject:notification];
}

-(void) addDeleteNoteNotification:(DeleteNoteNotification *)notificatoin
{
    [self.deleteNoteNotifications addObject:notificatoin];
}

-(void) addAddNoteNotification:(AddNoteNotification *)notification
{
    [self.addNoteNotifications addObject:notification];
}

-(void) addAddStackingNotification:(AddStackingNotification *)notification
{
    [self.addStackingNotifications addObject:notification];
}

-(void) addUpdateStackingNotification:(UpdateStackNotification *)notification
{
    [self.updateStackingNotifications addObject:notification];
}

-(void) addDeleteStackingNotification:(DeleteStackingNotification *)notification
{
    [self.deleteStackingNotifications addObject:notification];
}

-(void) clear
{
    [self.addNoteNotifications removeAllObjects];
    [self.updateNoteNotifications removeAllObjects];
    [self.deleteNoteNotifications removeAllObjects];
    [self.addStackingNotifications removeAllObjects];
    [self.updateStackingNotifications removeAllObjects];
    [self.deleteStackingNotifications removeAllObjects];
}

@end
