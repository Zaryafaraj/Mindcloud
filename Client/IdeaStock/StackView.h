//
//  StackView.h
//  IdeaStock
//
//  Created by Ali Fathalian on 5/16/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteView.h"
#import "StackView.h"

@interface StackView : UIView <BulletinBoardObject,UITextViewDelegate>

@property (strong,nonatomic) NSMutableArray * views;

@property (weak, nonatomic) NoteView * mainView;

-(id) initWithViews: (NSMutableArray *) views 
        andMainView: (NoteView *) mainView
          withFrame: (CGRect) frame;

-(void) setNextMainViewWithNoteToRemove:(NoteView *) noteView;

-(void) addNoteView:(NoteView *) note;

-(void) removeNoteView:(NoteView *) note;

-(NSSet *) getAllNoteIds;

@end
