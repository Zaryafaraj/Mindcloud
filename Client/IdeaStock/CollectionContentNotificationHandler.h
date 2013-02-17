//
//  CollectionContentNotificationHandler.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/16/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CollectionContentNotificationHandler <NSObject>

-(void) noteUpdateReceivedForCollectionNamed: (NSString *) collectionName
                                andNoteNamed:(NSString *) noteName
                                withNoteData:(NSData *) noteData;


-(void) noteImageUpdateReceivedForCollectionName:(NSString *) collectionName
                                    andNoteNamed: (NSString *) noteName
                               withNoteImageData:(NSData *) imageData;

-(void) noteDeleteReceivedForCollectionName:(NSString *) collectionName
                               andNoteNamed:(NSString *) noteName;

-(void) collectionManifestReceivedForCollectionName:(NSString *) collectionName
                                           withData:(NSData *) data;

@end
