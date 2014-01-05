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

@protocol StackActionDelegate <NSObject>

-(void) expandStackPressed:(id) sender;
-(void) deleteStackPressed:(id) sender;

@end

@interface StackView : UIView <BulletinBoardObject,UITextViewDelegate>

@property (strong, atomic) NSMutableArray * views;

@property (weak, nonatomic) id<StackActionDelegate> delegate;

@property (weak, nonatomic, readonly) NoteView * mainView;

-(id) initWithViews: (NSMutableArray *) views 
        andMainView: (NoteView *) mainView
          withFrame: (CGRect) frame
         andScaling:(CGFloat) scaleOffset;

-(void) setTopViewForNote:(NoteView *) newNote;

-(void) addNoteView:(NoteView *) note;

-(void) removeNoteView:(NoteView *) note;

-(void) stackWillClose;

-(void) stackWillOpen;

-(void) stackDidFinishMoving;

-(NSSet *) getAllNoteIds;

-(void) setTopItem:(NoteView *) note;

@end
