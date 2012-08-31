//
//  CallBackDataModel.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/6/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
A data model that follows this protocol should use the delegate to 
 provide call backs for all data model operations. 
 */
@protocol CallBackDataModel <NSObject>

@property (nonatomic,weak) id delegate; 

@end
