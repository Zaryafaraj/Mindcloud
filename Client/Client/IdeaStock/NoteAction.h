//
//  NoteAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface NoteAction : MindcloudBaseAction

typedef void (^get_note_callback)(NSData * noteData);
typedef void (^delete_note_callback)(void);

@property (nonatomic, strong) get_note_callback getCallback;
@property (nonatomic, strong) delete_note_callback deleteCallback;

-(id) initWithUserId: (NSString *) userID
       andCollection: (NSString *) collectionName
             andNote: (NSString *) noteName;
@end
