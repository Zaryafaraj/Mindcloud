//
//  SharingAwareObject.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/5/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SharingAwareObject <NSObject>

-(void) collectionIsShared:(NSString *) collectionName;
-(void) collectionIsNotShared:(NSString *) collectionName;

@end
