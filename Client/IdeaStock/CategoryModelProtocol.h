//
//  CategoryModelProtocol.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/8/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CategoryModelProtocol <NSObject>

-(NSArray *) getAllSerializableCategories;
-(NSArray *) getSerializableCollectionsForCategory: (NSString *) category;

@end
