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

@end
