//
//  DeleteNoteNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "DeleteAssociationNotification.h"
@interface DeleteAssociationNotification()

@property (atomic, strong) NSString * associationId;
@property (atomic, strong) NSString * refId;

@end
@implementation DeleteAssociationNotification

-(id) initWithAssociationId: (NSString *) associationId
                   andRefId: (NSString *) refId
{
    self.refId = refId;
    self.associationId = associationId;
    return self;
}

-(NSString *) getAssociationId
{
    return self.associationId;
}

-(NSString *) getRefId
{
    return self.refId;
}

@end
