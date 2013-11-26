//
//  DiffFileAction.m
//  Mindcloud
//
//  Created by Ali Fathalian on 11/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "DiffFileAction.h"
#import "HTTPHelper.h"

@implementation DiffFileAction

-(id) initWithUserId:(NSString *) userId
   andCollectionName:(NSString *) collectionName
    andSharingSecret:(NSString *) sharingSecret
  andSharingSpaceURL:(NSString *) url
         andFilename:(NSString *) filename
             andPath:(NSString *) path
andBase64FileContent:(NSData *) content
{
    self = [super init];
    if (self)
    {
        NSString * resourcePath = [NSString stringWithFormat:@"%@/SharingSpace/%@/B64Diff", url, sharingSecret];
        NSURL * url = [NSURL URLWithString:resourcePath];
        NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL:url
                                                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                               timeoutInterval:60.0];
        self.request = theRequest;
        self.request.HTTPMethod = @"POST";
        NSDictionary * params = @{@"user_id" : userId,
                                  @"collection_name" : collectionName,
                                  @"resource_path" : resourcePath};
        self.request = [HTTPHelper addPostFile:self.postData
                                      withName:filename
                                     andParams:params
                                            to:self.request];
    }
    return self;
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    
    if ([self.request.HTTPMethod isEqualToString:@"POST"])
    {
        if (self.lastStatusCode != 200 && self.lastStatusCode != 304)
        {
            NSLog(@"Received status %d", self.lastStatusCode);
            self.postCallback(NO);
        }
        else
        {
            self.postCallback(YES);
        }
    }
}
@end
