//
//  XoomlNoteModel.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "XoomlNoteModel.h"

@implementation XoomlNoteModel

-(id) initWithName:(NSString *) noteName
      andPositionX:(NSString *) positionX
      andPositionY: (NSString *) positionY
        andScaling:(NSString *) scaling
{
    self = [super init];
    _noteName = noteName;
    _positionX = positionX;
    _positionY = positionY;
    _scaling = scaling;
    return self;
}

@end
