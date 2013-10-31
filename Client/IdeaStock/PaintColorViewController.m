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

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    UIColor * selectedColor = cell.backgroundColor;
    self.selectedColor = selectedColor;
    self.samplePathView.lineColor = selectedColor;
    id<PaintColorDelegate> temp = self.delegate;
    if (temp)
    {
        [temp paintColorSelected:selectedColor];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.allowsSelection = YES;
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    self.samplePathView.lineWidth = self.currentBrushWidth;
    self.samplePathView.lineColor = self.selectedColor;
}

-(void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.selectedColor == nil) return;
    
    NSArray * allColors = [self.model getAllColors];
    for(int i= 0 ; i < allColors.count; i++)
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UIColor * aColor = [self.model colorForIndexPath:indexPath];
        if ([self.selectedColor isEqual:aColor])
        {
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            return;
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
