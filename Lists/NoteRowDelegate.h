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
-(void) tappedRow:(UIView<ListRow> *) sender;
-(BOOL) isEditingRows;
@end
