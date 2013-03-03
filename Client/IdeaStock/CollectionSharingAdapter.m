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

#define UPDATE_MANIFEST_KEY @"update_manifest"
#define UPDATE_NOTE_KEY @"update_note"
#define UPDATE_NOTE_IMG_KEY @"update_note_img"
#define DELETE_NOTE_KEY @"delete_note"
#define UPDATE_THUMBNAIL_KEY @"update_thumbnail"

@interface CollectionSharingAdapter()
@property (strong, nonatomic) NSString * collectionName;
@property (strong, nonatomic) NSString * sharingSecret;
@property (strong, nonatomic) NSString * sharingSpaceURL;
@property (strong, nonatomic) id<CollectionSharingAdapterDelegate> delegate;
@end
@implementation CollectionSharingAdapter

-(id) initWithCollectionName:(NSString *)collectionName
                 andDelegate:(id<CollectionSharingAdapterDelegate>)delegate
{
    self.collectionName = collectionName;
    self.delegate = delegate;
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
    //primary listener
    [self listen];
    //backup listener
    [self listen];
}

-(void) listen
{
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    //add to Listeners
    [mindcloud addListenerTo:self.sharingSpaceURL forSharingSecret:self.sharingSecret andCollection:self.collectionName forUser:userId withCallback:^(NSDictionary * result){
        NSLog(@"backup listener notified");
        if (result != nil)
        {
            [self processListenerResult:result];
            [self listen];
        }
    }];
}

-(void) processListenerResult:(NSDictionary *) result
{
    for (NSString * eventKey in result)
    {
        if ([eventKey isEqualToString:UPDATE_MANIFEST_KEY])
        {
            [self.delegate manifestGotUpdated:result[eventKey]];
        }
        if ([eventKey isEqualToString:UPDATE_NOTE_KEY])
        {
            [self.delegate notesGotUpdated:result[eventKey]];
        }
        if([eventKey isEqualToString:UPDATE_NOTE_IMG_KEY])
        {
            [self.delegate noteImagesGotUpdated:result[eventKey]];
        }
        if ([eventKey isEqualToString:DELETE_NOTE_KEY])
        {
            [self.delegate notesGotDeleted:result[eventKey]];
        }
        if ([eventKey isEqualToString:UPDATE_THUMBNAIL_KEY])
        {
            [self.delegate thumbnailGotUpdated:result[eventKey]];
        }
    }
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
