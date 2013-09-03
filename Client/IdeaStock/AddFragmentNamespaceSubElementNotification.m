//
//  AddFragmentNamespaceSubElementNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "AddFragmentNamespaceSubElementNotification.h"

@interface AddFragmentNamespaceSubElementNotification()

@property (atomic, strong) XoomlNamespaceElement * subElement;
@property (atomic, strong) XoomlFragmentNamespaceElement * parentFragmentNamespace;

@end
@implementation AddFragmentNamespaceSubElementNotification


-(id) initWithSubelement:(XoomlNamespaceElement *) subElement
    andFragmentNamespace:(XoomlFragmentNamespaceElement *) fragmentNamespace
{
    self.subElement = subElement;
    self.parentFragmentNamespace = fragmentNamespace;
    return self;
}


-(XoomlNamespaceElement *) getSubElement
{
    return self.subElement;
}

-(XoomlFragmentNamespaceElement *) getParentFragmentNamespaceElement
{
    return self.parentFragmentNamespace;
}

@end
