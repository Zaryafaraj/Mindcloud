//
//  MindcloudBaseAction.m
//  IdeaStock
//
//  Created by Ali Fathalian on 9/22/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "MindcloudBaseAction.h"

@interface MindcloudBaseAction()

//should be set if the response is not JSON
@end

@implementation MindcloudBaseAction

@synthesize baseURL = _baseURL;
@synthesize receivedData = _receivedData;
@synthesize request = _request;


-(NSMutableData *)receivedData
{
    if (!_receivedData)
    {
        _receivedData = [NSMutableData data];
    }
    return _receivedData;
}

-(NSDictionary *) getDataAsDictionary
{
    if ([self.receivedData length] > 0)
    {
        NSError * err;
        NSDictionary * result = [NSJSONSerialization JSONObjectWithData:self.receivedData
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&err];
        if (!result)
        {
            //result is not a dictionary read it as a string and put it as status
            NSString *dataStr = [[NSString alloc] initWithData:self.receivedData
                                                      encoding:NSUTF8StringEncoding];
            result = @{STATUS_KEY:dataStr};
        }
        return result;
    }
    else
    {
        return @{};
    }
}

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
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    self.lastStatusCode = code;
}

/*
 Since objective c doesn't have abstract classes
 Subclasses should implement these
 */
-(void) executeGET
{
    // create the connection with the request
    // and start loading the data
    //The default method for the request is GET
    //we expect to recieve JSON
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
}

-(void) executePOST
{
    return;
}

-(void) executePUT
{
    return;
}

-(void) executeDELETE
{
    [self.request setHTTPMethod:@"DELETE"];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    if (!theConnection)
    {
        NSLog(@"Failed to connect to %@", self.request.URL);
    }
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
          [error userInfo][NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //enable for debug
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //enable for debug
    /*
    if (self.lastStatusCode == 200){
        NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    }
    else
    {
        NSLog(@"Got Response %d",  self.lastStatusCode);
    }
    if ([self.receivedData length] > 0)
    {
        NSString *dataStr = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", dataStr);
    }*/
}
@end