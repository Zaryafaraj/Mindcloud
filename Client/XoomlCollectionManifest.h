//
//  XoomlBulletinBoardController.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/1/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CollectionManifestProtocol.h"

/*
 Provides functionality for working the xooml datamodel of the bulletin 
 board. 
 
 This class does not provide any guruantees about the integrity of the 
 created xooml file. For exmple it doesn't make sure that the things that
 are unique are kept unique. 
 
 It is the responsibility of the callers of this class methods to make sure 
 that the integrity rules are kept. 
 
 The reason for this decision is that keeping the integrity in the code level
 has less perforamnce penality than keeping it in the xooml level. 
 */

@interface XoomlCollectionManifest : NSObject <CollectionManifestProtocol>

/*Convinience method*/
+ (NSData *) getEmptyBulletinBoardData;

-(id) initWithDocument:(DDXMLDocument *) document;

@end
