//
//  MindcloudSharingAdapter.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "AllCollectionsSharingAdapter.h"
#import "EventTypes.h"
#import "UserPropertiesHelper.h"
#import "NetworkActivityHelper.h"

@interface AllCollectionsSharingAdapter()

@property (strong, atomic) NSMutableDictionary * cache;

@end
@implementation AllCollectionsSharingAdapter

-(id) init
{
    self = [super init];
    self.cache = [NSMutableDictionary dictionary];
    return self;
}

-(void) shareCollection:(NSString *) collectionName
{
    if (self.cache[collectionName])
    {
        NSDictionary * userInfo = @{@"result" : @{@"collectionName" : collectionName,
                                                          @"sharingSecret": self.cache[collectionName]}};
        [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_SHARED
                                                            object:self
                                                          userInfo:userInfo];
    }
    else
    {
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userId = [UserPropertiesHelper userID];
        [mindcloud shareCollection:collectionName ForUser:userId withCallback:^(NSString *sharingSecret) {
            if (sharingSecret != nil)
            {
                self.cache[collectionName] = sharingSecret;
                NSDictionary * userInfo = @{@"result" : @{@"collectionName" : collectionName,
                                                          @"sharingSecret": self.cache[collectionName]}};
                [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_SHARED
                                                                    object:self
                                                                  userInfo:userInfo];
            }
            else
            {
                //the lack of the sharing secret means that the action failed
                NSDictionary * userInfo = @{@"result" : @{@"collectionName" : collectionName}};
                [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_SHARED
                                                                    object:self
                                                                  userInfo:userInfo];
                                            }
        }];
        
    }
}

-(void) unshareCollection:(NSString *) collectionName
{
    [self.cache removeObjectForKey:collectionName];
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud unshareCollection:collectionName forUser:userId withCallback:^{
        NSDictionary * userInfo = @{@"result" : @{@"collectionName" : collectionName}};
        [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_UNSHARED
                                                            object:self
                                                            userInfo:userInfo];
    }];
}

-(void) subscriberToCollection:(NSString *)sharingSecret
{
    [NetworkActivityHelper addActivityInProgress];
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud subscribeToCollectionWithSecret:sharingSecret
                                       forUser:userId
                                  withCallback:^(NSString * collectionName)
     {
         [NetworkActivityHelper removeActivityInProgress];
         if (collectionName)
         {
             NSDictionary * userInfo = @{@"result" : @{@"collectionName" : collectionName}};
             [[NSNotificationCenter defaultCenter] postNotificationName:SUBSCRIBED_TO_COLLECTION
                                                                 object:self
                                                               userInfo:userInfo];
             NSLog(@"Subscribed to collection : %@", collectionName);
             self.cache[collectionName] = sharingSecret;
                 
         }
         else
         {
             NSDictionary * userInfo = @{@"result" : @{}};
             [[NSNotificationCenter defaultCenter] postNotificationName:SUBSCRIBED_TO_COLLECTION
                                                                 object:self
                                                               userInfo:userInfo];
             NSLog(@"failed to subscribe : %@", sharingSecret);
             
         }
     }];
}
@end
