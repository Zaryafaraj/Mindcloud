//
//  ExternalFileHelper.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ExternalFileHelper.h"

@implementation ExternalFileHelper

+(NSString *) fileNameForDrawingWithIndex:(NSNumber *) index
{
    return [NSString stringWithFormat:@"BoardDrawing%@",index];
}
@end
