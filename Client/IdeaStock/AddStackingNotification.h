//
//  AddStackingNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddStackingNotification : NSObject

-(id) initWithStackingId:(NSString *) stackingId
                andScale:(NSString *) scale
                andNoteRefs:(NSArray *) notes;

-(NSString *) getStackId;
-(NSString *) getScale;
-(NSArray *) getNoteRefs;

@end
