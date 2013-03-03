//
//  CollectionSharingAdapterDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CollectionSharingAdapterDelegate <NSObject>

-(void) manifestGotUpdated:(NSString *) manifestContent;
-(void) notesGotUpdated:(NSDictionary *) noteUpdateDict;
-(void) notesGotDeleted:(NSDictionary *) noteDeleteDict;
-(void) noteImagesGotUpdated:(NSDictionary *) noteImagesDict;
-(void) thumbnailGotUpdated:(NSString *) thumbnailPath;

@end
