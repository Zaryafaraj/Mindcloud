//
//  UpdateNoteImageNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateNoteImageNotification : NSObject

-(id) initWithNoteId:(NSString *) noteId
      andNoteContent:(NSString *) noteContent
    andNoteImagePath:(NSString *) noteImagePath;

-(NSString *) getNoteId;
-(NSString *) getNoteContent;
-(NSString *) getNoteImagePath;
@end
