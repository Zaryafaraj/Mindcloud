//
//  CategoryModelProtocol.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/8/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CategoryModelProtocol <NSObject>

-(NSArray *) getAllCategories;
-(NSArray *) getCollectionsForCategory: (NSString *) category;
-(int) numberOfCollectionsInCategory: (NSString *) category;
-(int) numberOfCategories;

@optional

-(NSString *) getCollectionAt: (int) index forCategory: (NSString *) cat;

@end
