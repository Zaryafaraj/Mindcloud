//
//  CollectionAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 1/9/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CollectionAction.h"
@interface CollectionAction()

@end

@implementation CollectionAction

-(id) initWithUserId:(NSString *)userId
       andCollection:(NSString *)collectionName
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Collections/%@", userId, collectionName];
    NSURL * url = [NSURL URLWithString:[self.baseURL stringByAppendingString:resourcePath]];
    
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    self.request = theRequest;
    return self;
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    //TODO figure out a way to handle 404 and stuff
    [super connectionDidFinishLoading:connection];
    if (self.getCallback)
    {
        self.getCallback(self.receivedData);
    }
}
@end
