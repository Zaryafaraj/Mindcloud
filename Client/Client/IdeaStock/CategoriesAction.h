//
//  CategoriesAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/10/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindcloudBaseAction.h"
@interface CategoriesAction : MindcloudBaseAction

typedef void (^get_categories_callback)(NSData * category);
typedef void (^save_categories_callback)(void);

@property (nonatomic, strong) get_categories_callback getCallback;
@property (nonatomic, strong) save_categories_callback postCallback;
@property (nonatomic, strong) NSData * categoriesData;

-(id) initWithUserID:(NSString *)userID;

@end
