//
//  CollectionsModel.h
//  IdeaStock
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryModelProtocol.h"
#import "MindcloudAllCollectionsDelegate.h"
#import "SynchronizedObject.h"
#import "MindcloudAllCollectionsGordonDelegate.h"

#define SHARED_COLLECTIONS_KEY @"Shared"
#define UNCATEGORIZED_KEY @"Uncategorized"
#define ALL @"All Collections"

@interface MindcloudAllCollections : NSObject <CategoryModelProtocol, MindcloudAllCollectionsGordonDelegate>

-(id) initWithDelegate:(id<MindcloudAllCollectionsDelegate>) delegate;

-(id) initWithCollections:(NSArray *) collections
              andDelegate:(id<MindcloudAllCollectionsDelegate>) delegate;

-(id) initWithCollections:(NSArray *)collections
            andCategories: (NSDictionary *) categories
              andDelegate:(id<MindcloudAllCollectionsDelegate>) delegate;

-(void) applyCategories:(NSDictionary *) categories;

//async
-(NSArray *) getAllCollections;

-(NSArray *) getAllCategories;

-(NSDictionary *) getAllCategoriesMappings;

-(NSArray *) getEditableCategories;

-(NSArray *) getCollectionsForCategory: (NSString *) category;

-(void) cleanup;

//promises to save the categories at one point not neccessarily now
-(void) promiseSavingAllCategories;

-(void) addCollection: (NSString *) collection toCategory: (NSString *) category;

-(void) addCategory: (NSString *) category;

-(void) removeCollection:(NSString *) collection fromCategory: (NSString *) cateogry;

-(void) batchRemoveCollections:(NSArray *) collections
                  fromCategory:(NSString *) category;

-(void) removeCategory: (NSString *) category;

-(void) renameCategory: (NSString *) category
              toNewCategory: (NSString *) newCategory;

-(void) renameCollection:(NSString *) collection
                   inCategory: (NSString *) category
              toNewCollection: (NSString *) newCollection;

-(void) moveCollection: (NSString *) collectionName
          fromCategory: (NSString *) oldCategory
         toNewCategory: (NSString *) newCategory;


-(NSSet *) getAllCollectionNames;

-(BOOL) canRemoveCategory: (NSString *) category;

-(BOOL) isCategoryEditable:(NSString *) categoryName;

-(int) numberOfCollectionsInCategory: (NSString *) category;

-(int) numberOfCategories;

-(NSString *) getCollectionAt:(int)index
                  forCategory:(NSString *)cat;

-(void) setImageData: (NSData *) imgData
       forCollection: (NSString *) collectionName;

-(NSData *) getImageDataForCollection: (NSString *) collectionName;

-(void) subscribeToCollectionWithSecret:(NSString *) sharingSecret;

-(void) shareCollection:(NSString *) collectionName;

-(void) unshareCollection:(NSString *) collectionName;

-(void) refresh;

@end
