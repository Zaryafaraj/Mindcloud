//
//  BulletinBoardDatasource.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/1/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 This protocol is the main protocol for retrieval and storage to the 
 data model. 
 
 The implementation should provide for deserializing a bulletinboard
 from raw data and converting the bulletin board to a form that is
 serializable. 
 
 */
@protocol BulletinBoardDatasource <NSObject>

/*
 Initialize the data source with raw data in data. 
 
 It is up to the implementor to decide which data structures to use or 
 how to produce a bulletin board specific properties out of this data
 
 The method does not gurantee anything about the validity of the data.
 */
-(id) initWithData: (NSData *) data;

-(id) initAsEmpty;
/*
 Serializes the bulletin board into raw data that is ready for serialization.
 
 The method guruantees that the returned data is valid. 
 */
- (NSData *) data;



@end
