//
//  AddNoteNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "AddAssociationNotification.h"
@interface AddAssociationNotification()

@property (atomic, strong) XoomlAssociation * association;

@end

@implementation AddAssociationNotification

-(id) initWithAssociation:(XoomlAssociation *)association
{
    self.association = association;
    return self;
}

-(XoomlAssociation *) getAssociation
{
    return self.association;
}

@end
