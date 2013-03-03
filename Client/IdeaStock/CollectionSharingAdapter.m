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
            NSLog(@"collection is Not Shared");
            self.isShared = NO;
        }
        else
        {
            NSLog(@"collection is Shared");
            self.isShared = YES;
            NSLog(@"%@", sharingInfo);
        }
    }];
}

@end
