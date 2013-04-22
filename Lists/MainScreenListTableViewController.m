//
//  ListMainPageViewController.m
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "MainScreenListTableViewController.h"
#import "MainScreenRow.h"

@interface MainScreenListTableViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation MainScreenListTableViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        MainScreenRow * row = [[MainScreenRow alloc] init];
        self.navigationBar.alpha = 0.7;
        row.delegate = self;
        self.prototypeRow =row;
    }
    return self;
}

- (IBAction)addPressed:(id)sender
{
    [self addRowToTop];
}

#pragma mark - MainScreenRow Delegate
-(void) deletePressed:(MainScreenRow *)sender
{
    [self removeRow:sender];
}

-(void) sharePressed:(MainScreenRow *)sender
{
    
}

-(void) renamePressed:(MainScreenRow *)sender
{
    
}

@end
