//
//  DeleteNoteNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeleteNoteNotification : NSObject
-(id) initWithNoteId:(NSString *) noteId;
-(NSString *) getNoteId;
@end
