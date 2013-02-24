//
//  MindcloudSharingAdapter.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mindcloud.h"

@interface MindcloudSharingAdapter : NSObject

-(void) shareCollection:(NSString *) collectionName;
-(void) unshareCollection:(NSString *) collectionName;
@end
