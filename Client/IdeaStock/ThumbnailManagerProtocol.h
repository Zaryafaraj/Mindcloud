//
//  ThumbnailManagerProtocol.h
//  Mindcloud
//
//  Created by Ali Fathalian on 2/9/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThumbnailManagerProtocol <NSObject>

-(BOOL) isUpdateThumbnailNeccessary;
-(NSData *) getLastThumbnailImage;
@end
