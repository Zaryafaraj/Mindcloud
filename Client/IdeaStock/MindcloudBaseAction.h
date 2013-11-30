//
//  MindcloudBaseAction.h
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MINDCLOUD_BASE_URL @"http://localhost:8000/"
//@"http://192.168.1.6:8000/"
//@"http://10.200.187.18:8000/"
//@"http://192.168.1.57:8000/"
//@"http://ec2-54-235-217-101.compute-1.amazonaws.com:8000/"
#define STATUS_KEY @"status"

@interface MindcloudBaseAction : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic,readonly) NSString * baseURL;
@property (atomic,strong) NSMutableURLRequest * request;
@property (nonatomic,strong) NSMutableData* receivedData;
@property int lastStatusCode;

//TODO find a way to make this protected
/**
 Subclasses should implement the execute method
 */
- (void) executeGET;
- (void) executePOST;
- (void) executeDELETE;
- (void) executePUT;

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
