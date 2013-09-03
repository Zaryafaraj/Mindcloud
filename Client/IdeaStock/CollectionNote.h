//
//  XoomlNote.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteProtocol.h"
#import "XoomlFragment.h"

@interface CollectionNote : NSObject <NoteProtocol>

-(CollectionNote *) initEmptyNoteWithID:(NSString *)noteID
                                   andDate: (NSString *)date;

-(CollectionNote *) initWithText:(NSString *)text
                       andNoteId:(NSString *) noteId;

-(CollectionNote *) initEmptyNoteWithID: (NSString *) noteID;

-(CollectionNote *) initWithText: (NSString *) text;

@end
