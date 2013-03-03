//
//  CollectionSharingAdapter.m
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionSharingAdapter.h"
#import "Mindcloud.h"
#import "UserPropertiesHelper.h"
#import "EventTypes.h"

@interface CollectionSharingAdapter()
@property (strong, nonatomic) NSString * collectionName;
@property (strong, nonatomic) NSString * sharingSecret;
@property (strong, nonatomic) NSString * sharingSpaceURL;
@end
@implementation CollectionSharingAdapter

-(id) initWithCollectionName:(NSString *)collectionName
{
    self.collectionName = collectionName;
    return self;
}

-(void) getSharingInfo
{
    
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud getSharingInfo:self.collectionName forUser:userId andCallback:^(NSDictionary * sharingInfo){
        if (sharingInfo == nil)
        {
            self.isShared = NO;
        }
        else
        {
            NSLog(@"collection is Shared");
            self.isShared = YES;
            self.sharingSecret = sharingInfo[@"secret"];
            self.sharingSpaceURL = sharingInfo[@"sharing_space_url"];
            NSDictionary * userInfo = @{@"result" :@{@"collectionName":self.collectionName}};
            [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_IS_SHARED object:self userInfo:userInfo];
        }
    }];
}

-(void) startListening
{
    
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    //add to Listeners
    [mindcloud addListenerTo:self.sharingSpaceURL forSharingSecret:self.sharingSecret andCollection:self.collectionName forUser:userId withCallback:^(NSDictionary * result){
        NSLog(@"%@", result);
    }];
    //backup listener
    [mindcloud addListenerTo:self.sharingSpaceURL forSharingSecret:self.sharingSecret andCollection:self.collectionName forUser:userId withCallback:^(NSDictionary * result){
        NSLog(@"%@", result);
    }];
}

-(void) stopListening
{
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud closeListenersToURL:self.sharingSpaceURL forSharingSecret:self.sharingSecret andCollection:self.collectionName forUser:userId withCallback:^(void){
        //nothing for now
    }];
}
@end
