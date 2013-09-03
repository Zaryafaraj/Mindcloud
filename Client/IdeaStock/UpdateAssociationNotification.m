//
//  UpdateNoteNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "UpdateAssociationNotification.h"
@interface UpdateAssociationNotification()

@property (atomic, strong) XoomlAssociation * association;

@end

@implementation UpdateAssociationNotification

-(id) initWithAssociation:(XoomlAssociation *) association
{
    self.association = association;
    return self;
}

-(XoomlAssociation *) getAssociation
{
    return self.association;
}

@end
