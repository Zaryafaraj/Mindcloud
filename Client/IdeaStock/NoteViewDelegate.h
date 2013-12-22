//
//  NoteViewDelegate.h
//  IdeaStock
//
//  Created by Ali Fathalian on 5/20/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NoteViewDelegate 

@property (nonatomic, strong) UIView * activeView;
-(void) note:(id) note changedTextTo: (NSString *)text;

-(void) noteDeletePressed:(id) note;

@end
