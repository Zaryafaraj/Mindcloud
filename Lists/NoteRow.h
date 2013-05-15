//
//  NoteRow.h
//  Lists
//
//  Created by Ali Fathalian on 4/30/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RowLayoutManagerProtocol.h"
#import "NoteRowDelegate.h"
#import "AwesomeMenu.h"

@interface NoteRow : UIView <ListRow, UITextFieldDelegate, AwesomeMenuDelegate>

@property (nonatomic, strong) id<RowLayoutManagerProtocol> layoutManager;

@property (nonatomic, strong) id<NoteRowDelegate> delegate;

@property (readonly) BOOL isExpanded;

-(int) numberOfSubNotes;

@end
