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
-(NSData *) getThumbnailForCollection:(NSString *) collectionName;

-(NSDictionary *) getAllCategoriesMappings;

-(void) shareCollection:(NSString *) collectionName;

-(void) unshareCollection:(NSString *) collectionName;

-(void) subscribeToCollectionWithSecret:(NSString *) secret;

//async method
-(NSArray *) getAllCollections;

-(void) promiseSavingCategories;

-(void) saveCategories;

-(void) cleanup;

-(void) refresh;
@end
