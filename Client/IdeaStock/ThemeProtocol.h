//
//  ITheme.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/27/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThemeProtocol <NSObject>

-(UIColor *) tintColor;

-(UIColor *) collectionBackgroundColor;

-(UIColor *) backgroundColorForAllCollectionCategory;

-(UIColor *) backgroundColorForUncategorizedCategory;

-(UIColor *) backgroundColorForSharedCategory;

-(UIColor *) backgroundColorForCustomCategory;

@end
