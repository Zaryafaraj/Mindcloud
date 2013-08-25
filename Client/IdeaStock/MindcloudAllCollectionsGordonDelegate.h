//
//  MindcloudAllCollectionsGordonDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 8/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MindcloudAllCollectionsGordonDelegate <NSObject>

-(void) collectionGotShared:(NSString *) collectionName;
-(void) collectionsLoaded:(NSArray *) allCollections;
-(void) categoriesLoaded:(NSDictionary *) allCategoriesMappings;
-(void) thumbnailLoadedForCollection:(NSString *) collectionName
                             andData:(NSData *) imgData;
-(NSData *) getCategoriesData;
@end
