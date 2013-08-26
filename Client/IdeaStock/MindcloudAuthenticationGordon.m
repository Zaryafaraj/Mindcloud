//
//  MindcloudGordonAuthentication.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudAuthenticationGordon.h"
#import "CachedMindCloudDataSource.h"
#import "MindcloudDataSource.h"

@interface MindcloudAuthenticationGordon()
@property (nonatomic, strong) id<MindcloudDataSource> dataSource;
@property (nonatomic, weak) id<MindcloudAuthenticationGordonDelegate> delegate;
@property (nonatomic, strong) NSString * authURL;
@property (nonatomic, strong) NSString * userId;
@end

@implementation MindcloudAuthenticationGordon

-(id) initWithUserId:(NSString *) userId
         andDelegate:(id<MindcloudAuthenticationGordonDelegate> ) del;
{
    self = [super init];
    if (self)
    {
        self.dataSource = [[CachedMindCloudDataSource alloc] init];
        self.userId = userId;
        self.delegate = del;
    }
    return self;
}

-(id<MindcloudAuthenticationGordonDelegate>) delegate
{
    if (_delegate != nil)
    {
        id<MindcloudAuthenticationGordonDelegate> tempDel = _delegate;
        return tempDel;
    }
    return nil;
}

-(NSString *) authenticationURL
{
    if (_authURL)
    {
        return _authURL;
    }
    return nil;
}

-(void) authorizeUser:(NSString *) userId
{
    [self.dataSource authorizeUser:userId withAuthenticationDelegate:self];
}

#pragma Authorization Delegate
-(void) didFinishAuthorizing:(NSString *)userID
          andNeedsAuthenting:(BOOL)needAuthenticating withURL:(NSString *)url
{
    
    if (needAuthenticating)
    {
        self.AuthURL = url;
    }
    else
    {
        id<MindcloudAuthenticationGordonDelegate> tempDel = self.delegate;
        if (tempDel)
        {
            [tempDel userIsAuthenticatedAndAuthorized:self.userId];
        }
    }
}

-(void) authorizationFailed
{
    //retry again
    [self authorizeUser:self.userId];
}

@end
