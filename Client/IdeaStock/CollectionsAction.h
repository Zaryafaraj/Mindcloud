//
//  AccountsAction.h
//  IdeaStock
//
//  Created by Ali Fathalian on 10/19/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface AccountsAction : MindcloudBaseAction

typedef void (^get_collections_callback)(NSArray * collections);
typedef void (^add_collection_callback)(void);

@property (nonatomic, strong) get_collections_callback getCallback;
@property (nonatomic, strong) add_collection_callback postCallback;
@property (nonatomic, strong) NSDictionary * postArguments;

-(id) initWithUserID:(NSString *) userID;

@end
