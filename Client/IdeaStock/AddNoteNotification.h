//
//  AddNoteNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddNoteNotification : NSObject

-(id) initWithNoteId:(NSString *) noteId
        andPositionX:(NSString *) positionX
        andPositionY:(NSString *) positionY
          andScaling:(NSString *) scaling;

-(NSString *) getNoteId;
-(NSString *) getPositionX;
-(NSString *) getPositionY;
-(NSString *) getScale;
@end
