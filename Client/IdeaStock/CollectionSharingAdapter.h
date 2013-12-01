//
//  CollectionSharingAdapter.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionSharingAdapterDelegate.h"
#import "DiffableSerializableObject.h"

@interface CollectionSharingAdapter : NSObject

@property BOOL isShared;

-(id)initWithCollectionName:(NSString *) collectionName
                andDelegate:(id<CollectionSharingAdapterDelegate>) delegate;

-(void) getSharingInfo;
-(void) startListening;
-(void) stopListening;

-(void) sendDiffFileWithPath:(NSString *) path
                 andFileName:(NSString *) filename
                  andContent:(id<DiffableSerializableObject>) content;

-(void) sendMessage:(NSString *) message
      withMessageId:(NSString *) messageId;

-(void) adjustListeners;

-(NSString *) getSharingSecret;
@end
