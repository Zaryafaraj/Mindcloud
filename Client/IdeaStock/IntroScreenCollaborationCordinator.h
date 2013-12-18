//
//  IntroScreenCollaborationCordinator.h
//  Mindcloud
//
//  Created by Ali Fathalian on 12/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TutorialScrollView.h"
#import "ImageNoteView.h"

@interface IntroScreenCollaborationCordinator : NSObject <TutorialScrollViewDelegate>

-(id) initWithLeftView:(TutorialScrollView *)leftView
          andRightView:(TutorialScrollView *)rightView;


-(void) startAnimationsWithImagePrototype:(ImageNoteView *) prototypeImageNote
                         andNotePrototype:(NoteView *) noteViewPrototype;
@end
