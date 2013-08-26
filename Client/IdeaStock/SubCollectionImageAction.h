//
//  Mindcloud
//
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface SubCollectionImageAction : MindcloudBaseAction

typedef void (^get_subcollection_image_callback)(NSData * subCollectionImageData);
typedef void (^add_subcollection_image_callback)(void);

@property (nonatomic, strong) get_subcollection_image_callback getCallback;
@property (nonatomic, strong) add_subcollection_image_callback postCallback;

@property (nonatomic, strong) NSData * postData;

-(id) initWithUserId: (NSString *) userID
       andCollection: (NSString *) collectionName
             andSubCollection: (NSString *) subCollectionName;
@end
