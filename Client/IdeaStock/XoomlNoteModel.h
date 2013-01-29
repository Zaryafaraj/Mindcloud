//
//  XoomlNoteModel.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XoomlNoteModel : NSObject
@property (readonly, strong) NSString * noteName;
@property (readonly, strong) NSString * positionX;
@property (readonly, strong) NSString * positionY;
@property (readonly, strong) NSString * scaling;

-(id) initWithName:(NSString *) noteName
      andPositionX:(NSString *) positionX
      andPositionY: (NSString *) positionY
        andScaling:(NSString *) scaling;
@end
