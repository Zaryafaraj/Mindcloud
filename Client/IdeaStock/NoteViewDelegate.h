//
//  NoteViewDelegate.h
//  IdeaStock
//
//  Created by Ali Fathalian on 5/20/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NoteViewDelegate 

-(void) note:(id) note changedTextTo: (NSString *)text;

@end
