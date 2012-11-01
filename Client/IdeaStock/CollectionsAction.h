//
//  AccountsAction.h
//  IdeaStock
//
//  Created by Ali Fathalian on 10/19/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface CollectionsAction : MindcloudBaseAction

typedef void (^get_collections_callback)(NSArray * collections);
typedef void (^add_collection_callback)(void);
typedef void (^delete_collection_callback)(void);
typedef void (^rename_collection_callback)(void);

@property (nonatomic, strong) get_collections_callback getCallback;
@property (nonatomic, strong) add_collection_callback postCallback;
@property (nonatomic, strong) delete_collection_callback deleteCallback;
@property (nonatomic, strong) rename_collection_callback putCallback;

@property (nonatomic, strong) NSDictionary * postArguments;
@property (nonatomic, strong) NSDictionary * putArguments;
@property (nonatomic, strong) NSString * deleteResource;
@property (nonatomic, strong) NSString * putResource;

-(id) initWithUserID:(NSString *) userID;

@end
