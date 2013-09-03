//
//  UpdateFragmentNamespaceElementNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "UpdateFragmentNamespaceElementNotification.h"

@interface UpdateFragmentNamespaceElementNotification()

@property (atomic, strong) XoomlFragmentNamespaceElement * fragmentNamespaceElem;

@end

@implementation UpdateFragmentNamespaceElementNotification

-(id) initWithFragmentNamespace: (XoomlFragmentNamespaceElement *)elem
{
    self.fragmentNamespaceElem = elem;
    return self;
}

-(XoomlFragmentNamespaceElement *) getFragmentNamespace
{
    return self.fragmentNamespaceElem;
}
@end
