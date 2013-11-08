//
//  HTTPHelper.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "HTTPHelper.h"

@implementation HTTPHelper

+(NSMutableURLRequest *)addPostFile:(NSData *)data
                           withName: (NSString *) fileName
                          andParams:(NSDictionary *)params
                                 to:(NSMutableURLRequest *)request
{
    NSString * boundary = @"----------------------------62ae4a76207c";
    NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",
                              boundary];
    [request addValue:contentType forHTTPHeaderField:@"content-type"];
    NSMutableData * postBody = [NSMutableData data];
    [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fileName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postBody appendData:[@"Content-Type: application/xml\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postBody appendData:[NSData dataWithData:data]];
    for (NSString * param in params)
    {
        NSString * paramName = param;
        NSString * paramValue = params[param];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:
         [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",paramName]
          dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"%@",paramValue]
                              dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postBody];
    return request;
}

+(NSMutableURLRequest *) addPostParams:(NSDictionary *) params
                                    to:(NSMutableURLRequest *) request
{
    return [self addPutParams:params to:request];
}
+(NSMutableURLRequest *) addPutParams:(NSDictionary *)params
                                   to:(NSMutableURLRequest *)request
{
    NSString * boundary = @"----------------------------62ae4a76207c";
    NSString * contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",
                              boundary];
    [request addValue:contentType forHTTPHeaderField:@"content-type"];
    
    NSMutableData * putBody = [NSMutableData data];
    [putBody appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    for (NSString * param in params)
    {
        NSString * paramName = param;
        NSString * paramValue = params[param];
        [putBody appendData:
         [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",paramName]
          dataUsingEncoding:NSUTF8StringEncoding]];
        [putBody appendData:[[NSString stringWithFormat:@"%@",paramValue]
                              dataUsingEncoding:NSUTF8StringEncoding]];
        
        [putBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [putBody appendData:[[NSString stringWithFormat:@"\r\n--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:putBody];
    return request;
}
@end
