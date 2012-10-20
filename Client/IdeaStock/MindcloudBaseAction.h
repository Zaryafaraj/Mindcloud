//
//  MindcloudBaseAction.h
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MindcloudBaseAction : NSObject <NSURLConnectionDelegate>

@property (nonatomic,readonly) NSString * baseURL;
@property (atomic,strong) NSMutableURLRequest * request;

//TODO find a way to make this protected
/**
 Subclasses should implement the execute method
 */
- (void) executeGET;
- (void) executePOST;

-(NSDictionary *) getDataAsDictionary;

/* ----------------
 Delegate Methods
------------------ */

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error;

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

@end
