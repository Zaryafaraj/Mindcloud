//
//  CollectionSharingAdapterDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CollectionSharingAdapterDelegate <NSObject>

-(void) collectionFragmentGotUpdated:(NSString *) collectionFragmentContent
             ForCollection:(NSString *) collectionName;

-(void) associatedItemGotUpdated:(NSDictionary *) associatedItemDict
      forCollectionName:(NSString *) collectionName;

-(void) associatedItemGotDeleted:(NSDictionary *) noteDeleteDict
      forCollectionName:(NSString *) collectionName;

-(void) associatedItemImagesGotUpdated:(NSDictionary *)noteImagesDict
           forCollectionName:(NSString *)collectionName
           withSharingSecret:(NSString *) sharingSecret
                  andBaseURL:(NSString *) baseURL;

-(void) thumbnailGotUpdated:(NSString *) thumbnailPath
          forCollectionName:(NSString *) collectionName
          withSharingSecret:(NSString *) sharingSecret
                 andBaseURL:(NSString *) baseURL;

-(void) diffFileReceivedForAssetAtPath:(NSString *) assetPath
                              withData:(NSData *) data;
@end
