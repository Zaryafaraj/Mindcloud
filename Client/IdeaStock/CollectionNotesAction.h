//
//  CollectionNotesAction.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface CollectionNotesAction : MindcloudBaseAction

typedef void (^get_all_notes_callback)(NSArray * allNotes);

@end
