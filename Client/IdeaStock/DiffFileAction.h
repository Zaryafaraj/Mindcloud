//
//  DiffFileAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface DiffFileAction : MindcloudBaseAction
typedef void (^diff_file_sent_callback)(BOOL);

@property (nonatomic, strong) diff_file_sent_callback postCallback;
@property (nonatomic, strong) NSData * postData;

-(id) initWithUserId:(NSString *) userId
   andCollectionName:(NSString *) collectionName
    andSharingSecret:(NSString *) sharingSecret
  andSharingSpaceURL:(NSString *) url
         andFilename:(NSString *) filename
             andPath:(NSString *) path
andBase64FileContent:(NSData *) content;

@end
