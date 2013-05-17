//
//  StubListTableViewDatasource.m
//  Lists
//
//  Created by Ali Fathalian on 4/20/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "StubListTableViewDatasource.h"

@interface StubListTableViewDatasource()

@property (strong, nonatomic) NSMutableDictionary * model;

@end

@implementation StubListTableViewDatasource

-(id) init
{
    self = [super init];
    self.model = [NSMutableDictionary dictionary];
    return self;
}

-(NSString *) titleForItemAtIndex:(int) index
{
    NSNumber * indexObj = [NSNumber numberWithInt:index];
    return self.model[indexObj];
}

-(UIImage *) imageForItemAtIndex:(int) index
{
    return [UIImage imageNamed:@"Test.png"];
}

-(void) setTitle:(NSString *) title
        ForItemAtIndex:(int) index
{
    NSNumber * indexObject = [NSNumber numberWithInt:index];
    if (self.model[indexObject])
    {
        self.model[indexObject] = title;
    }
}

-(void) setImage:(UIImage *) image
  ForItemAtIndex:(int) index
{
    ;
}

-(void) addItemWithTitle:(NSString *)title
                 atIndex:(int) index
{
    [self incrementAllIndexesAfterIndex:index-1];
    NSNumber * indexObj = [NSNumber numberWithInt:index];
    self.model[indexObj] = title;
}

-(void) incrementAllIndexesAfterIndex:(int) afterIndex
{
    NSMutableDictionary * newModel = [NSMutableDictionary dictionary];
    for(NSNumber * index in self.model.allKeys)
    {
        int newIndex = -1;
        NSString * title = nil;
        if ([index intValue] > afterIndex)
        {
            newIndex = [index intValue]+1;
            title = [NSString stringWithFormat:@"%d", newIndex];
            
        }
        else
        {
            newIndex = [index intValue];
            title = self.model[index];
        }
        
        NSNumber * newIndexObj = [NSNumber numberWithInt:newIndex];
        newModel[newIndexObj] = title;
    }
    self.model = newModel;
}

-(void) removeItemAtIndex:(int)index
{
    [self decrementAllIndexesAfterIndex:index-1];
}

-(void) decrementAllIndexesAfterIndex:(int)afterIndex
{
    NSMutableDictionary * newModel = [NSMutableDictionary dictionary];
    for(NSNumber * index in self.model.allKeys)
    {
        int newIndex = -1;
        if ([index intValue] > afterIndex)
        {
            newIndex = [index intValue]-1;
        }
        else
        {
            newIndex = [index intValue];
        }
        
        NSNumber * newIndexObj = [NSNumber numberWithInt:newIndex];
        if (newIndex >= 0)
        {
            newModel[newIndexObj] = self.model[index];
        }
    }
    self.model = newModel;
}

-(int) indexOfItemWithTitle:(NSString *)title
{
    for (NSNumber * index in self.model.allKeys)
    {
        if ([self.model[index] isEqualToString:title])
        {
            return [index intValue];
        }
    }
    return -1;
}


-(int) count
{
    return [self.model count];
}

#pragma mark - DataSource Indexer Protocol
-(int) numberOfItemsBeforeIndex:(int) index
{
    return 0;
}

-(int) numberOfItemsAfterIndex:(int) index
{
    return 0;
}

-(int) numberOfSubItemsBeforeIndex:(int) index
{
    return 0;
}

-(int) numberOfSubItemsAfterIndex:(int) index
{
    return 0;
}

-(int) numberOfSubItemsInIndex:(int) index
{
    return 0;
}
@end
