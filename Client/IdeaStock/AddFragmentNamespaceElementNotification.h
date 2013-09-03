//
//  AddStackingNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlFragmentNamespaceElement.h"

@interface AddFragmentNamespaceElementNotification : NSObject

-(id) initWithFragmentNamespace: (XoomlFragmentNamespaceElement *)elem;

-(XoomlFragmentNamespaceElement *) getFragmentNamespace;

@end
