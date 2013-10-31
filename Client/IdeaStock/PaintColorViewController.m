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
#import "BrushColors.h"

@interface PaintColorViewController ()

@property (weak, nonatomic) IBOutlet BrushSelectionView *samplePathView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) BrushColors * model;
@end

@implementation PaintColorViewController

-(BrushColors *) model
{
    if (!_model)
    {
        _model = [[BrushColors alloc] init];
    }
    return _model;
}

-(void) setCurrentBrushWidth:(CGFloat)currentBrushWidth
{
    _currentBrushWidth = currentBrushWidth;
    self.samplePathView.lineWidth = currentBrushWidth;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.model numberOfColors];
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColorCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell" forIndexPath:indexPath];
    UIColor * aColor = [self.model colorForIndexPath:indexPath];
    cell.backgroundColor = aColor;
    [cell adjustSelectedBorderColorBaseOnBackgroundColor:aColor withLightColors:[self.model getLightColors]];
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.dataSource = self;
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    self.samplePathView.lineWidth = self.currentBrushWidth;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
