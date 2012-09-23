//
//  MindcloudBaseAction.m
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface MindcloudBaseAction()

@property (nonatomic,strong) NSMutableData* receivedData;
@end

@implementation MindcloudBaseAction

@synthesize baseURL = _baseURL;
@synthesize receivedData = _receivedData;

-(NSMutableData *)receivedData
{
    if (!_receivedData)
    {
        _receivedData = [NSMutableData data];
    }
    return _receivedData;
}

#define MINDCLOUD_BASE_URL @"http://localhost:8000/"
-(NSString *) baseURL
{
    return MINDCLOUD_BASE_URL;
}
//TODO read this from a properties file

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    [self.receivedData setLength:0];
}

-(void) execute
{
    return;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    NSString *dataStr = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", dataStr);
}
@end
