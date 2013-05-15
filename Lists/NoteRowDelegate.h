//
//  NoteRowDelegate.h
//  Lists
//
//  Created by Ali Fathalian on 5/2/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NoteRowDelegate <NSObject>

-(void) deletePressed:(UIView<ListRowProtocol> *) sender;
-(void) doneTaskPressed:(UIView<ListRowProtocol> *) sender;
-(void) undoneTaskPressed:(UIView<ListRowProtocol> *) sender;
-(void) starPressed:(UIView<ListRowProtocol> *) sender;
-(void) clockPressed:(UIView<ListRowProtocol> *) sender;
-(void) expandPressed:(UIView<ListRowProtocol> *) sender;
-(void) unexpandPressed:(UIView<ListRowProtocol> *)sender;
-(void) tappedRow:(UIView<ListRowProtocol> *) sender;
-(BOOL) isEditingRows;
-(void) openSpaceForSubnotes:(int) noOfSubNotes;
@end
