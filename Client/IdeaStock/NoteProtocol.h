//
//  Note.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlFragment.h"
/**
 *Object for holding a single notes basic information.
 
 As it can be seen there are no information for the name of the note. 
 The reason for this is that a note is usually unnamed from the user perspective
 The name of the note is used primaraly from the bulletin board who uses this note
 to identify it so its stored separately as metadata for the note. 
 */
@protocol NoteProtocol <NSObject>

@required
@property (nonatomic,strong) NSString * noteText;

@property (nonatomic,strong) NSString * noteId;

@property (nonatomic,strong) NSString * image;

@property (nonatomic, strong) NSString * name;

- (NSString *) description;

-(instancetype) prototype;

-(instancetype) initWithXoomlFragment:(XoomlFragment *) fragment;

-(XoomlFragment *) toXoomlFragment;

@end
