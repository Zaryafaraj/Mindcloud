//
//  XoomlNote.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"
@interface BulletinBoardNote : NSObject <Note>

-(BulletinBoardNote *) initWithCreationDate: (NSString *) date;

-(BulletinBoardNote *) initEmptyNoteWithID:(NSString *)noteID 
                                   andDate: (NSString *)date;

-(BulletinBoardNote *) initEmptyNoteWithID: (NSString *) noteID;

-(BulletinBoardNote *) initWithText: (NSString *) text;
@end
