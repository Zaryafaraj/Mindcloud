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
#define TOTAL_LISTENERS 2
#define MAX_FAILURE_RETRIES 5
@interface CollectionSharingAdapter()
@property (strong, nonatomic) NSString * collectionName;
@property (strong, nonatomic) NSString * sharingSecret;
@property (strong, nonatomic) NSString * sharingSpaceURL;
@property (strong, nonatomic) id<CollectionSharingAdapterDelegate> delegate;
@property int listenerCount;
@property int failureCount;

@end
@implementation CollectionSharingAdapter

-(id) initWithCollectionName:(NSString *)collectionName
                 andDelegate:(id<CollectionSharingAdapterDelegate>)delegate
{
    self.collectionName = collectionName;
    self.delegate = delegate;
    self.listenerCount = 0;
    self.failureCount = 0;
    return self;
}

-(void) connectionFailed:(NSNotification *) notification
{
    NSDictionary* result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    NSString * sharingSecret = result[@"sharingSecret"];
    self.failureCount ++;
    if ([collectionName isEqualToString:self.collectionName]
        && [sharingSecret isEqualToString:self.sharingSecret]
        && self.failureCount < MAX_FAILURE_RETRIES)
    {
        self.listenerCount = 0;
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userId = [UserPropertiesHelper userID];
        [mindcloud getSharingInfo:self.collectionName forUser:userId andCallback:^(NSDictionary * sharingInfo){
            if (sharingInfo == nil)
            {
                self.isShared = NO;
            }
            else
            {
                self.isShared = YES;
                self.sharingSecret = sharingInfo[@"secret"];
                self.sharingSpaceURL = sharingInfo[@"sharing_space_url"];
                NSLog(@"ReEstablishing listeners");
                [self listen];
                [self listen];
            }
        }];
        }
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
            if([sharingInfo[@"sharing_space_url"] isKindOfClass:[NSString class]])
            {
                self.sharingSpaceURL = sharingInfo[@"sharing_space_url"];
            }
            NSDictionary * userInfo = @{@"result" :@{@"collectionName":self.collectionName}};
            [[NSNotificationCenter defaultCenter] postNotificationName:COLLECTION_IS_SHARED object:self userInfo:userInfo];
        }
    }];
}

-(void) startListening
{
    
    if (self.sharingSpaceURL == nil)
    {
        //try getting it again
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userId = [UserPropertiesHelper userID];
        [mindcloud getSharingInfo:self.collectionName forUser:userId andCallback:^(NSDictionary * sharingInfo){
            if (sharingInfo == nil)
            {
                self.isShared = NO;
            }
            else
            {
                self.isShared = YES;
                self.sharingSecret = sharingInfo[@"secret"];
                self.sharingSpaceURL = sharingInfo[@"sharing_space_url"];
                
                
                if([sharingInfo[@"sharing_space_url"] isKindOfClass:[NSString class]])
                {
                    self.sharingSpaceURL = sharingInfo[@"sharing_space_url"];
                    //primary listener
                    [self listen];
                    //backup listener
                    [self listen];
                }
                else
                {
                    self.sharingSpaceURL = nil;
                }
                
            }
        }];
    }
    else
    {
        //primary listener
        [self listen];
        //backup listener
        [self listen];
    }
}


-(void) adjustListeners
{
    while(self.listenerCount < TOTAL_LISTENERS)
    {
        [self listen];
    }
}

-(void) listen
{
    self.listenerCount++;
    NSLog(@"Started Listening; current listeners %d", self.listenerCount);
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    //add to Listeners
    [mindcloud addListenerTo:self.sharingSpaceURL forSharingSecret:self.sharingSecret andCollection:self.collectionName forUser:userId withCallback:^(NSDictionary * result){
        NSLog(@"listener notified");
        self.listenerCount--;
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
            NSLog(@"listener returned update manifest");
            [self.delegate manifestGotUpdated:result[eventKey]
                                ForCollection:self.collectionName];
        }
        if ([eventKey isEqualToString:UPDATE_NOTE_KEY])
        {
            NSLog(@"listener returned update note");
            [self.delegate notesGotUpdated:result[eventKey]
                         forCollectionName:self.collectionName];
        }
        if([eventKey isEqualToString:UPDATE_NOTE_IMG_KEY])
        {
            [self.delegate noteImagesGotUpdated:result[eventKey] forCollectionName:self.collectionName
                              withSharingSecret:self.sharingSecret
                                     andBaseURL:self.sharingSpaceURL];
            NSLog(@"listener returned update note img");
        }
        if ([eventKey isEqualToString:DELETE_NOTE_KEY])
        {
            [self.delegate notesGotDeleted:result[eventKey] forCollectionName:self.collectionName];
            NSLog(@"listener returned Delete Note");
        }
        if ([eventKey isEqualToString:UPDATE_THUMBNAIL_KEY])
        {
            NSLog(@"listener returned update thumbnail");
            [self.delegate thumbnailGotUpdated:result[eventKey] forCollectionName:self.collectionName
                             withSharingSecret:self.sharingSecret
                                    andBaseURL:self.sharingSpaceURL];
        }
    }
}

-(void) stopListening
{
    if (!self.isShared) return;
    
    self.listenerCount = 0;
    Mindcloud * mindcloud = [Mindcloud getMindCloud];
    NSString * userId = [UserPropertiesHelper userID];
    [mindcloud closeListenersToURL:self.sharingSpaceURL forSharingSecret:self.sharingSecret andCollection:self.collectionName forUser:userId withCallback:^(void){
        //nothing for now
    }];
}
@end
