//
//  NoteRowDelegate.h
//  Lists
//
//  Created by Ali Fathalian on 5/2/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NoteRowDelegate <NSObject>

-(void) deletePressed:(UIView<ListRow> *) sender;
-(void) doneTaskPressed:(UIView<ListRow> *) sender;
-(void) undoneTaskPressed:(UIView<ListRow> *) sender;
-(void) starPressed:(UIView<ListRow> *) sender;
-(void) clockPressed:(UIView<ListRow> *) sender;
-(void) expandPressed:(UIView<ListRow> *) sender;
-(void) unexpandPressed:(UIView<ListRow> *)sender;
-(void) tappedRow:(UIView<ListRow> *) sender;
-(BOOL) isEditingRows;
-(void) openSpaceForSubnotes:(int) noOfSubNotes;
@end
