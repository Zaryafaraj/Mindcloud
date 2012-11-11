//
//  PreviewImageAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/10/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface PreviewImageAction : MindcloudBaseAction

typedef void (^get_preview_callback)(NSData * category);
typedef void (^save_preview_callback)(void);

@property (nonatomic, strong) get_preview_callback getCallback;
@property (nonatomic, strong) save_preview_callback postCallback;
@property (nonatomic, strong) NSData * previewData;

-(id) initWithUserID:(NSString *) userID
       andCollection:(NSString *)collectionsName;
@end
