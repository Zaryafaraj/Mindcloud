//
//  CollectionsModel.h
//  IdeaStock
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryModelProtocol.h"
#define UNCATEGORIZED_KEY @"Uncategorized"
#define ALL @"All Collections"
#define SHARED_COLLECTIONS_KEY @"Shared"

@interface CollectionsModel : NSObject <CategoryModelProtocol>

-(id) init;
-(id) initWithCollections:(NSArray *) collections;
-(id) initWithCollections:(NSArray *)collections andCategories: (NSDictionary *) categories;

-(void) applyCategories:(NSDictionary *) categories;

-(NSArray *) getAllCategories;
-(NSArray *) getEditableCategories;
-(NSArray *) getCollectionsForCategory: (NSString *) category;

-(void) addCollection: (NSString *) collection toCategory: (NSString *) category;
-(void) addCategory: (NSString *) category;
-(void) removeCollection:(NSString *) collection fromCategory: (NSString *) cateogry;
-(void) removeCategory: (NSString *) category;
-(void) renameCategory: (NSString *) category
              toNewCategory: (NSString *) newCategory;
-(void) renameCollection:(NSString *) collection
                   inCategory: (NSString *) category
              toNewCollection: (NSString *) newCollection;
-(void) moveCollection: (NSString *) collectionName
          fromCategory: (NSString *) oldCategory
         toNewCategory: (NSString *) newCategory;

-(BOOL) doesNameExist: (NSString *) name;

-(BOOL) canRemoveCategory: (NSString *) category;

-(BOOL) isCategoryEditable:(NSString *) categoryName;

-(int) numberOfCollectionsInCategory: (NSString *) category;

-(int) numberOfCategories;

-(NSString *) getCollectionAt:(int)index
                  forCategory:(NSString *)cat;

-(void) setImageData: (NSData *) imgData
       forCollection: (NSString *) collectionName;

-(NSData *) getImageDataForCollection: (NSString *) collectionName;
@end
