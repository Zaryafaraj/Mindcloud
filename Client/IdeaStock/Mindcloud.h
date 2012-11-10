//
//  Mindcloud.h
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionsAction.h"
#import "AuthorizationDelegate.h"
#import "CategoriesAction.h"

@interface Mindcloud : NSObject

/*
 Factory method
 */
+(Mindcloud *) getMindCloud;

-(void) authorize:(NSString *) userId
     withDelegate: (id<AuthorizationDelegate>) delegate;

-(void) authorizationDone:(NSString *) userId;

-(void) getAllCollectionsFor:(NSString *) userId
                   WithCallback:(get_collections_callback)callback;

-(void) addCollectionFor: (NSString *) userID
                withName: (NSString *) collectionName
            withCallback: (add_collection_callback)callback;

-(void) deleteCollectionFor: (NSString *)userID
                   withName:(NSString *)collectionName
               withCallback:(delete_collection_callback) callback;

-(void) renameCollectionFor:(NSString *)userId
                   withName: (NSString *)collectionName
                withNewName: (NSString *) newCollectionName
               withCallback: (rename_collection_callback) callback;

-(void) getCategories: (NSString *) userId
         withCallback: (get_categories_callback) callback;

-(void) saveCategories: (NSString *) userId
              withData:(NSData *)categoriesData
           andCallback: (save_categories_callback) callback;
@end
