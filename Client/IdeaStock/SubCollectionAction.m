//
//  Mindcloud
//
//  Created by Ali Fathalian on 1/10/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "SubCollectionAction.h"

@implementation SubCollectionAction

-(id) initWithUserId: (NSString *) userID
       andCollection: (NSString *) collectionName
             andSubCollection: (NSString *) subCollectionName
{
    self = [super init];
    NSString * resourcePath = [NSString stringWithFormat:@"%@/Collections/%@/Notes/%@", userID, collectionName, subCollectionName];
    resourcePath = [resourcePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:
                   [self.baseURL stringByAppendingString:resourcePath]];
    NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
    self.request = theRequest;
    return self;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    
    if ([self.request.HTTPMethod isEqualToString:@"GET"])
    {
        
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.getCallback(nil);
            return;
        }
        
        self.getCallback(self.receivedData);
    }
    else if ([self.request.HTTPMethod isEqualToString:@"DELETE" ])
    {
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
        }
        
        self.deleteCallback();
        return;
    }
}
@end
