//
//  PaintColorViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/29/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "PaintColorViewController.h"
#import "ColorCell.h"
#import "BrushSelectionView.h"

@interface PaintColorViewController ()

@property (weak, nonatomic) IBOutlet BrushSelectionView *samplePathView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation PaintColorViewController

#define NUMBER_OF_COLORS 10 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return NUMBER_OF_COLORS;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColorCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    cell.layer.cornerRadius = 25;
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.dataSource = self;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
