//
//  UpdateNoteNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateNoteNotification : NSObject

-(id) initWithNoteId:(NSString *) noteId
        andPositionX:(NSString *) positionX
        andPositionY:(NSString *) positionY
            andScale:(NSString *) scale;

-(NSString *) getNoteId;
-(NSString *) getNotePositionX;
-(NSString *) getNotePositionY;
-(NSString *) getNoteScale;

@end
