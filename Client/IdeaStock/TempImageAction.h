//
//  TempImageAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface TempImageAction : MindcloudBaseAction
typedef void (^get_temp_image_callback)(NSData * imgData);

@property (nonatomic, strong) get_temp_image_callback getCallback;

-(id) initWithUserId:(NSString *) userId
       andCollection:(NSString *) collectionName
             andNote:(NSString *) noteName
       andTempSecret:(NSString *) imgSecret
              andURL:(NSString *) baseURL
    andSharingSecret:(NSString *) sharingSecret;
@end
