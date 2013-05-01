//
//  NoteRow.h
//  Lists
//
//  Created by Ali Fathalian on 4/30/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListTableRowLayoutManager.h"

@interface NoteRow : UIView <ListRow, UITextFieldDelegate>

@property (nonatomic, strong) id<ListTableRowLayoutManager> layoutManager;

@end
