//
//  DeleteFragmentNamespaceElementNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "DeleteFragmentNamespaceElementNotification.h"


@interface DeleteFragmentNamespaceElementNotification()

@property (atomic, strong) NSString * fragmentNamespaceID;
@end

@implementation DeleteFragmentNamespaceElementNotification

-(id) initWithFragmentNamespaceElementID:(NSString *) fragmentNamespaceId
{
    self.fragmentNamespaceID = fragmentNamespaceId;
    return self;
}

-(NSString *) getFragmentNamespaceElementId
{
    return self.fragmentNamespaceID;
}

@end
