//
//  CollectionAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/9/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface CollectionAction : MindcloudBaseAction

typedef void (^get_collection_callback)(NSData * collectionData);
typedef void (^update_collection_callback)(void);

@property (nonatomic, strong) get_collection_callback getCallback;
@property (nonatomic, strong) update_collection_callback postCallback;
@property (nonatomic, strong) NSData * postData;

-(id) initWithUserId:(NSString *) userId
       andCollection:(NSString *) collectionName;

@end
