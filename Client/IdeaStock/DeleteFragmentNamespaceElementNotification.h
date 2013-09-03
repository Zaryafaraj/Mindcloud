//
//  DeleteFragmentNamespaceElementNotification.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeleteFragmentNamespaceElementNotification : NSObject

-(id) initWithFragmentNamespaceElementID:(NSString *) fragmentNamespaceId;

-(NSString *) getFragmentNamespaceElementId;

@end

