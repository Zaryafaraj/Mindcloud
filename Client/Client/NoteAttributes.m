//
//  NoteAttributes.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "NoteAttributes.h"



@interface NoteAttributes()

//holds all the attributes for a note. This is a dictionary of arrays keyed on 
//attribute names. Each array for an attribute name contains all the values of
//NoteIDs for that attribute. Any other attribute that does not involve noteIDs
//should not be stored here. 
@property (nonatomic,strong) NSMutableDictionary * attributes;

@end

@implementation NoteAttributes

@synthesize positionY = _positionY;
@synthesize positionX = _positionX;
@synthesize attributes = _attributes;


// initialize self with a list of attributes. 
-(id) initWithAttributes:(NSArray *) attributes{
    self = [super init];
    self.attributes = [NSMutableDictionary dictionary];
    for (NSString * attribute in attributes){
        [self.attributes setObject:[NSMutableArray array] forKey:attributes];
    }
    return self;
    
}

-(void) addNoteID:(NSString *)noteID
 forAttributeName:(NSString *)attributeName{
    [[self.attributes objectForKey:attributeName] addObject:noteID];
}

-(NSArray *) getAllNotesForAttributeName:(NSString *)attributeName{
    return [[self.attributes objectForKey:attributeName] copy];
}

-(void) removeNoteID:(NSString *)noteID
    forAttributeName:(NSString *)attributeName{
    
    [[self.attributes objectForKey:attributeName] removeObject:noteID];
}

-(void) removeAttribute:(NSString *)attributeName{
    [self.attributes removeObjectForKey:attributeName];
}

@end
