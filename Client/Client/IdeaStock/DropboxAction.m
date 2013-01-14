
//
//  DropboxAction.m
//  IdeaStock
//
//  Created by Ali Fathalian on 5/29/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "DropboxAction.h"

#define ADD_BULLETIN_BOARD_ACTION @"addBulletinBoard"
#define UPDATE_BULLETIN_BOARD_ACTION @"updateBulletinBoard"
#define ADD_NOTE_ACTION @"addNote"
#define UPDATE_NOTE_ACTION @"updateNote"
#define ADD_IMAGE_NOTE_ACTION @"addImage"

@implementation DropboxAction

@synthesize action = _action;
@synthesize actionPath = _actionPath;
@synthesize actionBulletinBoardName = _actionBulletinBoardName;
@synthesize actionNoteName = _actionNoteName;
@synthesize actionFileName = _actionFileName;

@end
