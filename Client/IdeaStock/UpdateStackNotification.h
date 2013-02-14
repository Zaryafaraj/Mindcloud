//
//  UpdateStackNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateStackNotification : NSObject

-(id) initWithStackId:(NSString *) stackId
             andScale:(NSString *) scale
          andNoteRefs:(NSArray *) noteRefs;

-(NSString *) getStackId;
-(NSString *) getScale;
-(NSArray *) getNoteRefs;

@end
