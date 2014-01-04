//
//  NoteAnimator.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteView.h"

@interface NoteAnimator : NSObject

+(void) animateNoteHighlighted:(NoteView *) note
              withDeleteButton:(UIButton *) deleteButton;

+(void) animateNoteUnhighlighted:(NoteView *) note
                withDeleteButton:(UIButton *) deleteButton;

+(void) animateNoteSelectedInStack:(NoteView *) note;

+(void) animateNoteDeselectedInStack:(NoteView *) note;

@end
