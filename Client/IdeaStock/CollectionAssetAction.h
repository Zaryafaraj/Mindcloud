//
//  CollectionAssetAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/3/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface CollectionAssetAction : MindcloudBaseAction

typedef void (^save_collection_asset_callback)(BOOL didFinish);
typedef void (^get_collection_asset_callback)(NSData * collectionAsset);
typedef void (^delete_collection_asset_callback)(BOOL didDelete);

@property (nonatomic, strong) save_collection_asset_callback postCallback;
@property (nonatomic, strong) get_collection_asset_callback getCallback;
@property (nonatomic, strong) delete_collection_asset_callback deleteCallback;
@property (nonatomic, strong) NSString * sharingSecret;


@property (nonatomic, strong) NSData * postData;

-(id) initWithUserId:(NSString *) userId
       andCollection:(NSString *) collectionName
         andFileName:(NSString *) fileName;

@end
