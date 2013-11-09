//
//  CollectionAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/9/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface CollectionAction : MindcloudBaseAction

typedef void (^get_collection_callback)(NSData * collectionData, BOOL shouldSynchClient);

typedef void (^update_collection_callback)(void);
typedef void (^delete_collection_callback)(void);
typedef void (^rename_collection_callback)(void);

@property (nonatomic, strong) get_collection_callback getCallback;
@property (nonatomic, strong) update_collection_callback postCallback;
@property (nonatomic, strong) delete_collection_callback deleteCallback;
@property (nonatomic, strong) rename_collection_callback putCallback;
@property (nonatomic, strong) NSDictionary * putArguments;

@property (nonatomic, strong) NSData * postData;

-(id) initWithUserId:(NSString *) userId
       andCollection:(NSString *) collectionName;

@end
