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
@property (strong, nonatomic) BrushSelectionView * brushView;
@property (strong, nonatomic) UISlider * slider;
@property (strong, nonatomic) UIView * dividerLine;

@property (strong, nonatomic) UIButton * paintButton;
@property (strong, nonatomic) UIButton * undoButton;
@property (strong, nonatomic) UIButton * eraserButton;
@property (strong, nonatomic) UIButton * clearButton;

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
    [self addSubview:self.colorView];
    
    self.brushView = [[BrushSelectionView alloc] init];
    self.brushView.lineWidth = self.currentBrushWidth;
    self.brushView.lineColor = self.selectedColor;
    self.brushView.lineWidth = self.currentBrushWidth;
    self.brushView.lineColor = self.selectedColor;
    [self addSubview:self.brushView];
    
    self.slider = [[UISlider alloc] init];
    self.slider.minimumValue = self.minBrushWidth;
    self.slider.maximumValue = self.maxBrushWidth;
    self.slider.value = self.currentBrushWidth;
    [self.slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.slider];
    
    
    self.undoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.undoButton addTarget:self
                        action:@selector(undoPressed:)
              forControlEvents:UIControlEventTouchDown];
    [self.undoButton setTitle:@"undo" forState:UIControlStateNormal];
    [self addSubview:self.undoButton];
    
    self.paintButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.paintButton addTarget:self
                        action:@selector(paintPressed:)
              forControlEvents:UIControlEventTouchDown];
    [self.paintButton setTitle:@"paint" forState:UIControlStateNormal];
    [self addSubview:self.paintButton];
    
    self.eraserButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.eraserButton addTarget:self
                        action:@selector(eraserPressed:)
              forControlEvents:UIControlEventTouchDown];
    [self.eraserButton setTitle:@"erase" forState:UIControlStateNormal];
    [self addSubview:self.eraserButton];
    
    self.clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.clearButton addTarget:self
                        action:@selector(clearPressed:)
              forControlEvents:UIControlEventTouchDown];
    [self.clearButton setTitle:@"clear" forState:UIControlStateNormal];
    [self addSubview:self.clearButton];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor blackColor];
    self.dividerLine = lineView;
    [self addSubview:lineView];
    
}

- (void)sliderValueChanged:(id)sender {
    _currentBrushWidth = self.slider.value;
    self.brushView.lineWidth = _currentBrushWidth;
}

-(void) undoPressed:(id) sender
{
    id<PaintConfigDelegate> temp = self.delegate;
    if (temp)
    {
        [temp undoPressed];
    }
    
}

-(void) paintPressed:(id) sender
{
    id<PaintConfigDelegate> temp = self.delegate;
    if (temp)
    {
        [temp paintPressed];
    }
}

-(void) clearPressed:(id) sender
{
    id<PaintConfigDelegate> temp = self.delegate;
    if (temp)
    {
        [temp clearPressed];
    }
}

-(void) eraserPressed:(id) sender
{
    id<PaintConfigDelegate> temp = self.delegate;
    if (temp)
    {
        [temp eraserPressed];
    }
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
