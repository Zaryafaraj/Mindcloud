//
//  CollectionsModel.h
//  IdeaStock
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#define UNCATEGORIZED_KEY @"uncategorized"

@interface CollectionsModel : NSObject

-(id) init;
-(id) initWithCollections:(NSArray *) collections;
-(id) initWithCollections:(NSArray *)collections andCategories: (NSDictionary *) categories;

-(void) applyCategories:(NSDictionary *) categories;

-(void) addCollection: (NSString *) collection toCategory: (NSString *) category;
-(void) addCategory: (NSString *) category;
-(void) removeCollection:(NSString *) collection fromCategory: (NSString *) cateogry;
-(void) removeCategory: (NSString *) category;
-(NSArray *) getAllCategories;
-(NSArray *) getCollectionsForCategory: (NSString *) category;
-(void) renameCategory: (NSString *) category
              toNewCategory: (NSString *) newCategory;
-(void) renameCollection:(NSString *) collection
                   inCategory: (NSString *) category
              toNewCollection: (NSString *) newCollection;
-(void) moveCollection: (NSString *) collectionName
          fromCategory: (NSString *) oldCategory
         toNewCategory: (NSString *) newCategory;
-(NSString *) getCollectionAt: (int) index forCategory: (NSString *) cat;

-(BOOL) doesNameExist: (NSString *) name;

@end
