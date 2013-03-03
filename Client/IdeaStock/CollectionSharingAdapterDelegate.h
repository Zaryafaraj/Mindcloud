//
//  CollectionSharingAdapterDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CollectionSharingAdapterDelegate <NSObject>

-(void) manifestGotUpdated:(NSString *) manifestContent
             ForCollection:(NSString *) collectionName;

-(void) notesGotUpdated:(NSDictionary *) noteUpdateDict
      forCollectionName:(NSString *) collectionName;

-(void) notesGotDeleted:(NSDictionary *) noteDeleteDict
      forCollectionName:(NSString *) collectionName;

-(void) noteImagesGotUpdated:(NSDictionary *) noteImagesDict
           forCollectionName:(NSString *) collectionName;

-(void) thumbnailGotUpdated:(NSString *) thumbnailPath
      forCollectionName:(NSString *) collectionName;

@end
