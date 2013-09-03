//
//  UpdateFragmentNamespaceElementNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlFragmentNamespaceElement.h"

/*! We probably will never end up using this. The updates will be handled by
    indivdual UpdateFragmentNamespaceSubElementNotifications
 */
@interface UpdateFragmentNamespaceElementNotification : NSObject

-(id) initWithFragmentNamespace: (XoomlFragmentNamespaceElement *)elem;

-(XoomlFragmentNamespaceElement *) getFragmentNamespace;

@end
