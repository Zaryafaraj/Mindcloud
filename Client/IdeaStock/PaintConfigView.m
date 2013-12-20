//
//  PaintConfigView.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "PaintConfigView.h"
#import "BrushColors.h"
#import "ColorCell.h"
#import "BrushSelectionView.h"

@interface PaintConfigView()

@property (nonatomic, strong) UICollectionView * colorView;
@property (strong, nonatomic) BrushColors * model;
@property (strong, nonatomic) IBOutlet BrushSelectionView * brushView;
@property (strong, nonatomic) UISlider * slider;
@end

@implementation PaintConfigView

-(void) setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    
    if (self.selectedColor == nil) return;
    
    NSArray * allColors = [self.model getAllColors];
    for(int i= 0 ; i < allColors.count; i++)
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UIColor * aColor = [self.model colorForIndexPath:indexPath];
        if ([self.selectedColor isEqual:aColor])
        {
            [self.colorView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            return;
        }
    }
    
    self.brushView.lineColor = selectedColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self createSubViews];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self createSubViews];
    }
    return self;
}

-(void) createSubViews
{
    self.colorView = [[UICollectionView alloc] init];
    self.colorView.collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.colorView.dataSource = self;
    self.colorView.delegate = self;
    self.colorView.allowsSelection = YES;
    self.model = [[BrushColors alloc] init];
    
    self.brushView = [[BrushSelectionView alloc] init];
    self.brushView.lineWidth = self.currentBrushWidth;
    self.brushView.lineColor = self.selectedColor;
    
    self.slider = [[UISlider alloc] init];
    self.slider.minimumValue = self.minBrushWidth;
    self.slider.maximumValue = self.maxBrushWidth;
    self.slider.value = self.currentBrushWidth;
    [self.slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    self.brushView.lineWidth = self.currentBrushWidth;
    self.brushView.lineColor = self.selectedColor;
}

- (IBAction)sliderValueChanged:(id)sender {
    _currentBrushWidth = self.slider.value;
    self.brushView.lineWidth = _currentBrushWidth;
}

-(void) setMaxBrushWidth:(CGFloat)maxBrushWidth
{
    _maxBrushWidth = maxBrushWidth;
    self.slider.maximumValue = maxBrushWidth;
}

-(void) setMinBrushWidth:(CGFloat)minBrushWidth
{
    _minBrushWidth = minBrushWidth;
    self.slider.minimumValue = minBrushWidth;
}

-(void) setCurrentBrushWidth:(CGFloat)currentBrushWidth
{
    _currentBrushWidth = currentBrushWidth;
    self.slider.value = currentBrushWidth;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
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
    UICollectionViewCell * cell = [self.colorView cellForItemAtIndexPath:indexPath];
    UIColor * selectedColor = cell.backgroundColor;
    self.selectedColor = selectedColor;
    self.brushView.lineColor = selectedColor;
    id<PaintConfigDelegate> temp = self.delegate;
    if (temp)
    {
        [temp paintColorSelected:selectedColor];
    }
}

@end
