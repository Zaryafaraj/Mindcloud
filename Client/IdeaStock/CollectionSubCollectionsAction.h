//
//  Mindcloud
//
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface CollectionSubCollectionsAction : MindcloudBaseAction

typedef void (^get_all_subcollections_callback)(NSArray * allSubCollections);
typedef void (^add_subcollection_callback)(void);

@property (nonatomic, strong) get_all_subcollections_callback getCallback;
@property (nonatomic, strong) add_subcollection_callback postCallback;

@property (nonatomic, strong) NSDictionary * postArguments;
@property (nonatomic, strong) NSData * postData;

-(id) initWithUserID:(NSString *) userID
   andCollectionName:(NSString * ) collectionName;

@end
