//
//  NoteFragmentResolver.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlNoteModel.h"
#import "NoteProtocol.h"
@interface NoteFragmentResolver : NSObject

-(id) initWithCollectionName:(NSString *) collectionName;

-(void) noteContentReceived: (id <NoteProtocol>) noteContent
                  forNoteId:(NSString *) noteId;

-(void) noteModelReceived:(XoomlNoteModel *) noteModel
                forNoteId:(NSString *) noteId;

-(void) noteImagePathReceived:(NSString *) imagePath
                    forNoteId:(NSString *) noteId;
@end
