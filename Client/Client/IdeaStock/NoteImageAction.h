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
typedef void (^add_note_image_callback)(void);

@property (nonatomic, strong) get_note_image_callback getCallback;
@property (nonatomic, strong) add_note_image_callback postCallback;

@property (nonatomic, strong) NSData * postData;

-(id) initWithUserId: (NSString *) userID
       andCollection: (NSString *) collectionName
             andNote: (NSString *) noteName;
@end
