//
//  MindcloudAllCollectionsGordon.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MindcloudAllCollectionsGordonDelegate.h"

@interface MindcloudAllCollectionsGordon : NSObject

-(id) initWithDelegate:(id<MindcloudAllCollectionsGordonDelegate>) delegate;

-(void) addCollectionWithName:(NSString *) collectionName;

-(void) deleteCollectionWithName:(NSString *) collectionName;

-(void) renameCollectionWithName:(NSString *) collectionName

                              to:(NSString *) newCollectionName;

-(NSArray *) getAllCollections;

-(NSData *) getThumbnailForCollection:(NSString *) collectionName;

/*! Returns a dictionary of arrays. Each key is a categoryName and each value is an array of collectionNames 
    in that category */
-(NSDictionary *) getAllCategoriesMappings;


-(void) addEmptyCategory:(NSString *) categoryName;

-(void) addCategory:(NSString *) categoryName withCollections:(NSArray *) collectionNames;

-(void) addToCategory:(NSString *) categoryName collectionsWithNames:(NSArray *) collectionNAmes;

-(void) removeCategory:(NSString *) categoryName;

-(void) removeFromCategory:(NSString *) categoryName collectionsWithName:(NSArray *) collectionNames;

-(void) renameCategory:(NSString *) categoryName toNewName:(NSString *) newCategoryName;

-(void) moveCollection:(NSString *) collectionToMove
       fromOldCategory:(NSString *) oldCategory
         toNewCategory:(NSString *) newCategory;

/*! mapping dictionary is keyed on category name and valued on arrays. Each array contains all the collectoinNames
    In that category. This method will remove/add categories according to mapping so that it reflects exactly what
    mapping.
 */
-(void) applyCategories:(NSDictionary *) mapping;

-(void) shareCollection:(NSString *) collectionName;

-(void) unshareCollection:(NSString *) collectionName;

-(void) subscribeToCollectionWithSecret:(NSString *) secret;

-(void) refresh;
@end
