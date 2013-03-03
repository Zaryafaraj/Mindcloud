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

-(void) noteImagesGotUpdated:(NSDictionary *)noteImagesDict
           forCollectionName:(NSString *)collectionName
           withSharingSecret:(NSString *) sharingSecret
                  andBaseURL:(NSString *) baseURL;

-(void) thumbnailGotUpdated:(NSString *) thumbnailPath
          forCollectionName:(NSString *) collectionName
          withSharingSecret:(NSString *) sharingSecret
                 andBaseURL:(NSString *) baseURL;

@end
