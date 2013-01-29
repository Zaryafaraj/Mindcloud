//
//  StackingModel.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XoomlStackingModel : NSObject

@property (readonly, strong, nonatomic) NSArray * refIds;
@property (readonly)  NSString * scale;
@property (readonly, strong, nonatomic) NSString * name;

-(id) initWithName:(NSString *) name
            andScale:(NSString *) scale
           andRefIds: (NSArray *) refIds;
@end
