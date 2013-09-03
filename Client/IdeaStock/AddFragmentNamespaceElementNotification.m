//
//  AddStackingNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "AddFragmentNamespaceElementNotification.h"

@interface AddFragmentNamespaceElementNotification()

@property (atomic, strong) XoomlFragmentNamespaceElement * fragmentNamespaceElem;

@end

@implementation AddFragmentNamespaceElementNotification


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
