//
//  CollectionBoardState.h
//  Mindcloud
//
//  Created by Ali Fathalian on 12/27/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionBoardState : NSObject

@property (nonatomic, strong) NSMutableSet * touchedViews;
@property (nonatomic, strong) NSMutableSet * validUndoView;
@property (nonatomic, strong) NSMutableDictionary * allDrawings;
@property (nonatomic, strong) NSMutableSet * overlappingViewsFromLastTouch;
@property (nonatomic, assign) NSInteger orderIndex;

@end
