//
//  DeleteStackingNotification.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "DeleteFragmentNamespaceSubElementNotification.h"

@interface DeleteFragmentNamespaceSubElementNotification()

@property (atomic, strong) NSString * subElementId;
@property (atomic, strong) XoomlFragmentNamespaceElement * fragmentNamespace;

@end
@implementation DeleteFragmentNamespaceSubElementNotification

-(id) initWithSubelement:(NSString *) subElementId
    andFragmentNamespace:(XoomlFragmentNamespaceElement *) fragmentNamespace
{
    self.subElementId = subElementId;
    self.fragmentNamespace = fragmentNamespace;
    return self;
}

-(NSString *) getSubElementId
{
    return self.subElementId;
}

-(XoomlFragmentNamespaceElement *) getParentFragmentNamespaceElement
{
    return self.fragmentNamespace;
}
@end
