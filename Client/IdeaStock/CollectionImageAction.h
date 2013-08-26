//
//  PreviewImageAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/10/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface CollectionImageAction : MindcloudBaseAction

typedef void (^get_collection_image_callback)(NSData * imgData);
typedef void (^save_collection_image_callback)(void);

@property (nonatomic, strong) get_collection_image_callback getCallback;
@property (nonatomic, strong) save_collection_image_callback postCallback;
@property (nonatomic, strong) NSData * previewData;

-(id) initWithUserID:(NSString *) userID
       andCollection:(NSString *)collectionsName;
@end
