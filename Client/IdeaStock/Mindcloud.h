//
//  Mindcloud.h
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountsAction.h"

@interface Mindcloud : NSObject

/*
 Factory method
 */
+(Mindcloud *) getMindCloud;

-(void) authorize:(NSString *) userId;

-(void) authorizationDone:(NSString *) userId;

-(void) getAllBulletinBoardsFor:(NSString *) userId
                   WithCallback:(get_collections_callback)callback;

@end
