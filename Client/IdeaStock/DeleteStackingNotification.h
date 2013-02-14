//
//  DeleteStackingNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeleteStackingNotification : NSObject

-(id) initWithStackingId:(NSString *) stackingId;

-(NSString *) getStackingId;
@end

