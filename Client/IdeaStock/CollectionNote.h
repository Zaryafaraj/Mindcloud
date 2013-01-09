//
//  XoomlNote.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"
@interface CollectionNote : NSObject <Note>

-(CollectionNote *) initWithCreationDate: (NSString *) date;

-(CollectionNote *) initEmptyNoteWithID:(NSString *)noteID 
                                   andDate: (NSString *)date;

-(CollectionNote *) initEmptyNoteWithID: (NSString *) noteID;

-(CollectionNote *) initWithText: (NSString *) text;
@end
