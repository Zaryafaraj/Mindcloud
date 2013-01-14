//
//  CachedCollectionDataModel.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/8/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CachedCollectionDataModel.h"

@implementation CachedCollectionDataModel

- (void) addNote: (NSString *)noteName 
     withContent: (NSData *) note 
    ToCollection: (NSString *) collectionName
{
    
}

-(void) addImageNote: (NSString *) noteName
     withNoteContent: (NSData *) note 
            andImage: (NSData *) img 
   withImageFileName: (NSString *)imgName
     toCollection: (NSString *) collectionName;
{
    
}

-(void) updateCollectionWithName: (NSString *) collectionName
               andContent: (NSData *) content
{
    
}


-(void) updateNote: (NSString *) noteName 
       withContent: (NSData *) conetent
   inCollection:(NSString *) collectionName
{
    
}

- (void) removeNote: (NSString *) noteName
  FromCollection: (NSString *) collectionName
{
    
}


- (NSData *) getCollection: (NSString *) collectionName
{
    return nil;
}

- (NSData *) getNoteForTheCollection: (NSString *) collectionName
                                   WithName: (NSString *) noteName
{
    return nil;
}

- (NSData *) getImage: (NSString *) imgName
              ForNote: (NSString *)noteID 
            andCollection: (NSString *) bulletinBoardName
{
    return nil;
}
@end
