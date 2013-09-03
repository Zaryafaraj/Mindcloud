//
//  DeleteStackingNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlNamespaceElement.h"
#import "XoomlFragmentNamespaceElement.h"

@interface DeleteFragmentNamespaceSubElementNotification : NSObject

-(id) initWithSubelement:(NSString *) subElementId
    andFragmentNamespace:(XoomlFragmentNamespaceElement *) fragmentNamespace;


-(NSString *) getSubElementId;
-(XoomlFragmentNamespaceElement *) getParentFragmentNamespaceElement;

@end

