//
//  CategorizationViewDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 3/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CategorizationViewDelegate <NSObject>

-(void) categorizationHappenedForCategory:(NSString *) categoryName;

@end
