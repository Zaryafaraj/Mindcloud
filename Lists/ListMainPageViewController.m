//
//  ListMainPageViewController.m
//  Lists
//
//  Created by Ali Fathalian on 4/6/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListMainPageViewController.h"

@interface ListMainPageViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * collections;
@end

@implementation ListMainPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
    }
    return self;
}

#pragma mark - Table View Delegate/DataSource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.collections count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CollectionTitleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor lightGrayColor];
    cell.contentView.alpha = 0.5;
    cell.textLabel.text = self.collections[indexPath.item];
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collections = [NSMutableArray array];
    [self.collections addObject:@"ALi"];
    [self.collections addObject:@"Leila"];
    [self.collections addObject:@"Three"];
    [self.collections addObject:@"Four"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect tableFrame = CGRectMake(self.tableView.frame.origin.x,
                                   self.tableView.frame.origin.y,
                                   self.tableView.frame.size.width,
                                   2 * [self.collections count]);
    self.tableView.frame = tableFrame;
}
@end
