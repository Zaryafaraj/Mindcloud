//
//  CategorizationViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 3/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "CategorizationViewController.h"

@interface CategorizationViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CategorizationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if (self.rowHeight > 0){
        self.tableView.rowHeight = self.rowHeight;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"CategorizationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.categories[indexPath.item];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section + 1 for add place holder
    //FIXME: a hack to add an empty cell below everything else so that the last cel won't get cut off
    return [self.categories count];
}

-(CGSize)getBestPopoverContentSize
{
    if ([self.categories count] > 0)
    {
        return CGSizeMake(200, [self.categories count] * self.rowHeight);
    }
    else
    {
        return CGSizeMake(0, 0);
    }
}
@end
