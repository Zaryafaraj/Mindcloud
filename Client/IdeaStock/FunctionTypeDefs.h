//
//  FunctionTypeDefs.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/20/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FunctionTypeDefs <NSObject>

typedef void (^update_note_location_function)(NoteView * note);
typedef void (^animate_delete_finished)(void);
typedef void (^layout_unstack_finished)(void);
typedef void (^animate_unstack_finished)(void);
typedef void (^move_noted_finished)(void);
@end
