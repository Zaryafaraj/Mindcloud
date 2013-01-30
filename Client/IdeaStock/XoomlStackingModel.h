//
//  StackingModel.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XoomlStackingModel : NSObject

@property (readonly, strong, nonatomic) NSSet * refIds;
@property NSString * scale;
@property (strong, nonatomic) NSString * name;

-(id) initWithName:(NSString *) name
            andScale:(NSString *) scale
         andRefIds: (NSSet *) refIds;

-(void) addNotes:(NSSet *) notes;

-(void) deleteNotes:(NSSet *) notes;
@end
