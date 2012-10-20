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

-(id) initWithUserID:(NSString *) userID
         andCallback:(get_collections_callback)callback;

@end
