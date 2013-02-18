//
//  CollectionRecorder.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionRecorder : NSObject

-(void) recordDeleteNote:(NSString *) noteId;
-(void) recordUpdateNote:(NSString *) noteId;
-(void) recordDeleteStack:(NSString *) stackId;
-(void) recordUpdateStack:(NSString *) stackId;

-(NSSet *) getDeletedNotes;
-(NSSet *) getDeletedStacks;
-(NSSet *) getUpdatedNotes;
-(NSSet *) getUpdatedStacks;

-(BOOL) hasStackingBeenTouched:(NSString *) stackingId;
-(BOOL) hasNoteBeenTouched:(NSString *) noteId;
-(BOOL) hasAnythingBeenTouched;
-(void) reset;
@end
