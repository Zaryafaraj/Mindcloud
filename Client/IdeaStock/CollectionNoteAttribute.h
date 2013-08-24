//
//  XoomlNoteModel.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CollectionNoteAttribute : NSObject
@property (readonly, strong) NSString * noteName;
@property (nonatomic, strong) NSString * positionX;
@property (nonatomic, strong) NSString * positionY;
@property (nonatomic, strong) NSString * scaling;

-(id) initWithName:(NSString *) noteName
      andPositionX:(NSString *) positionX
      andPositionY: (NSString *) positionY
        andScaling:(NSString *) scaling;
@end
