//
//  CollectionSharingAdapter.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/2/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionSharingAdapter : NSObject

@property BOOL isShared;

-(id)initWithCollectionName:(NSString *) collectionName;
-(void) getSharingInfo;
@end
