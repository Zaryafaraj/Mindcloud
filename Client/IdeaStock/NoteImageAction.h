//
//  NoteImageAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface NoteImageAction : MindcloudBaseAction

typedef void (^get_note_image_callback)(NSData * note_image_Data);

@end
