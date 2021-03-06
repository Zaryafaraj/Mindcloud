//
//  DeleteNoteNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeleteAssociationNotification : NSObject

-(id) initWithAssociationId: (NSString *) associationId
                   andRefId: (NSString *) refId;

-(NSString *) getAssociationId;
-(NSString *) getRefId;

@end
