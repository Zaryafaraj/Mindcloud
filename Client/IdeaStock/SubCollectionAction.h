//
//  Mindcloud
//
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface SubCollectionAction : MindcloudBaseAction

typedef void (^get_subcollection_callback)(NSData * subCollectionData);
typedef void (^delete_subcollection_callback)(void);

@property (nonatomic, strong) get_subcollection_callback getCallback;
@property (nonatomic, strong) delete_subcollection_callback deleteCallback;

-(id) initWithUserId: (NSString *) userID
       andCollection: (NSString *) collectionName
             andSubCollection: (NSString *) subCollectionName;
@end
