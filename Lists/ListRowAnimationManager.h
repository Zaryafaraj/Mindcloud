//
//  ListRowAnimationManager.h
//  Lists
//
//  Created by Ali Fathalian on 4/20/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ListRowAnimationManager <NSObject>

-(void) slideOpenMainScreenRow:(UIView *) row withButtons: (NSArray *) buttons;

-(void) slideCloseMainScreenRow:(UIView *) row withButtons: (NSArray *) buttons;

@end
