//
//  CollectionContentNotificationHandler.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/16/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CollectionContentNotificationHandler <NSObject>

-(void) noteUpdatesReceivedForCollectionNamed: (NSString *) collectionName
                                     andNotes:(NSDictionary *) noteDataMap;

-(void) noteImageUpdateReceivedForCollectionName:(NSString *)collectionName
                                    andNoteNamed:(NSString *)noteName
                               withNoteImageData:(NSData *)imageData;

-(void) noteDeletesReceivedForCollectionName:(NSString *) collectionName
                                     andNotes:(NSDictionary *) noteDataMap;

-(void) collectionManifestReceivedForCollectionName:(NSString *) collectionName
                                           withData:(NSData *) data;

@end
