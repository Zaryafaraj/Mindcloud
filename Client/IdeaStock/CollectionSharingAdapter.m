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

#define UPDATE_COLLECTION_FRAGMENT_KEY @"update_manifest"
#define UPDATE_ASSOCIATION_KEY @"update_note"
#define UPDATE_ASSOCIATION_IMG_KEY @"update_note_img"
#define DELETE_ASSOCIATION_KEY @"delete_note"
#define UPDATE_THUMBNAIL_KEY @"update_thumbnail"
#define DIFF_FILE_RECEIVED @"send_diff_file"
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

-(void) sendDiffFileWithPath:(NSString *) path
                 andFileName:(NSString *) filename
                  andContent:(id<DiffableSerializableObject>) content
{
    if (self.sharingSpaceURL != nil)
    {
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userId = [UserPropertiesHelper userID];
        NSData * base64Data = [[content serializeToData]base64EncodedDataWithOptions:0];
        [mindcloud sendDiffFileForUser:userId
                         andCollection:self.collectionName
                    andSharingSpaceURL:self.sharingSpaceURL
                      andSharingSecret:self.sharingSecret
                          withFileName:filename
                               andPath:path
                      andBase64Content:base64Data
                           andCallback:^(BOOL finished){
                               ;
                           }];
    }
    else
    {
        //its not shared do nothing
//        NSLog(@"CollectionSharingAdapter - SharingSpaceURL Not Set");
    }
}

-(void) processListenerResult:(NSDictionary *) result
{
    for (NSString * eventKey in result)
    {
        if ([eventKey isEqualToString:UPDATE_COLLECTION_FRAGMENT_KEY])
        {
            NSLog(@"CollectionSharingAdapter - listener returned update Collection Fragment");
            [self.delegate collectionFragmentGotUpdated:result[eventKey]
                                ForCollection:self.collectionName];
        }
        if ([eventKey isEqualToString:UPDATE_ASSOCIATION_KEY])
        {
            NSLog(@"CollectionSharingAdapter - listener returned update Association");
            [self.delegate associatedItemGotUpdated:result[eventKey]
                         forCollectionName:self.collectionName];
        }
        if([eventKey isEqualToString:UPDATE_ASSOCIATION_IMG_KEY])
        {
            [self.delegate associatedItemImagesGotUpdated:result[eventKey] forCollectionName:self.collectionName
                              withSharingSecret:self.sharingSecret
                                     andBaseURL:self.sharingSpaceURL];
            NSLog(@"CollectionSharingAdapter - listener returned update association img");
        }
        if ([eventKey isEqualToString:DELETE_ASSOCIATION_KEY])
        {
            [self.delegate associatedItemGotDeleted:result[eventKey] forCollectionName:self.collectionName];
            NSLog(@"CollectionSharingAdapter - listener returned Delete association");
        }
        if ([eventKey isEqualToString:UPDATE_THUMBNAIL_KEY])
        {
            NSLog(@"CollectionSharingAdapter -listener returned update thumbnail");
            [self.delegate thumbnailGotUpdated:result[eventKey] forCollectionName:self.collectionName
                             withSharingSecret:self.sharingSecret
                                    andBaseURL:self.sharingSpaceURL];
        }
        if ([eventKey isEqualToString:DIFF_FILE_RECEIVED])
        {
            NSLog(@"CollectionSharingAdapter - Diff File received");
            NSDictionary * diffs = result[eventKey];
            for(NSString * diffFilePath in diffs)
            {
                NSString * value = diffs[diffFilePath];
                //decode from base64
                NSData * diffData = [[NSData alloc] initWithBase64EncodedString:value
                                                                        options:0];
                [self.delegate diffFileReceivedForAssetAtPath:diffFilePath
                                                     withData:diffData];
            }
            
        }
    }
}

-(void) sendMessage:(NSString *) message
      withMessageId:(NSString *) messageId
{
    
    if (self.sharingSpaceURL != nil)
    {
        Mindcloud * mindcloud = [Mindcloud getMindCloud];
        NSString * userId = [UserPropertiesHelper userID];
        [mindcloud sendMessageForUser:userId
                        andCollection:self.collectionName
                   andSharingSpaceURL:self.sharingSpaceURL
                     andSharingSecret:self.sharingSecret
                           andMessage:message
                         andMessageId:messageId
                          andCallback:^(BOOL callback){;}];
    }
    else
    {
        //its not shared do nothing
//        NSLog(@"CollectionSharingAdapter - SharingSpaceURL Not Set");
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
