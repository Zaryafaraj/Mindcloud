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
#import "ThemeFactory.h"
#define MAX_BRUSH_WIDTH 25.0f
#define MIN_BRUSH_WIDTH 2.0f
#define DEFAULT_BRUSH_WIDTH 3.0f

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

@property (nonatomic,assign) BOOL isInPaintMode;
@property (nonatomic,assign) BOOL isInEraseMode;

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

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        [self createSubViews];
//    }
//    return self;
//}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self createSubViews];
    }
    return self;
}


-(id) init
{
    if (self = [super init])
    {
        [self createSubViews];
    }
    return self;
}

#define EDGE_OFFSET 10.0
#define DISTANCE_BETWEEN_SLIDER_AND_COLORS 20
#define DISTANCE_BETWEEN_BOTTOMS_AND_DIVIDER 10
#define DISTANCE_BETWEEN_DIVIDER 15
#define DISTANCE_BETWEEN_BUTTONS 5
#define ICON_SIZE 50

-(void) createSubViews
{
    
    UICollectionViewFlowLayout * layoutManager = [[UICollectionViewFlowLayout alloc] init];
    layoutManager.minimumInteritemSpacing = 0;
    layoutManager.minimumLineSpacing = 0;
    layoutManager.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layoutManager.sectionInset = UIEdgeInsetsZero;
    layoutManager.itemSize = CGSizeMake(50, 50);
    
    UICollectionView * colorView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                                      collectionViewLayout:layoutManager];
    colorView.contentInset = UIEdgeInsetsZero;
    self.colorView = colorView;
    self.colorView.dataSource = self;
    self.colorView.delegate = self;
    self.colorView.allowsSelection = YES;
    self.colorView.bounces = YES;
    self.colorView.showsHorizontalScrollIndicator = NO;
    self.model = [[BrushColors alloc] init];
    self.colorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.colorView.backgroundColor = [UIColor clearColor];
    [self.colorView registerClass:[ColorCell class] forCellWithReuseIdentifier:@"ColorCell"];
    [self addSubview:self.colorView];
    
    BrushSelectionView * brushView = [[BrushSelectionView alloc] init];
    self.brushView = brushView;
    self.currentBrushWidth = DEFAULT_BRUSH_WIDTH;
    self.selectedColor = [[ThemeFactory currentTheme] defaultColorForDrawing];
    self.brushView.lineWidth = self.currentBrushWidth;
    self.brushView.lineColor = self.selectedColor;
    self.brushView.lineWidth = self.currentBrushWidth;
    self.brushView.lineColor = self.selectedColor;
    self.brushView.translatesAutoresizingMaskIntoConstraints = NO;
    self.brushView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.brushView];
    
    UISlider * slider = [[UISlider alloc] init];
    self.slider = slider;
    self.slider.minimumValue = self.minBrushWidth;
    self.slider.maximumValue = self.maxBrushWidth;
    [self.slider addTarget:self
                    action:@selector(sliderValueChanged:)
          forControlEvents:UIControlEventValueChanged];
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    self.slider.maximumValue = MAX_BRUSH_WIDTH;
    self.slider.minimumValue = MIN_BRUSH_WIDTH;
    self.slider.value = self.currentBrushWidth;
    [self addSubview:self.slider];
    
    
    UIButton * undoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.undoButton = undoButton;
    [self.undoButton addTarget:self
                        action:@selector(undoPressed:)
              forControlEvents:UIControlEventTouchDown];
    self.undoButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage * btnImage = [[ThemeFactory currentTheme] iconForUndoControl];
    [self.undoButton setImage:btnImage
                     forState:UIControlStateNormal];
    self.undoButton.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControlButton];
    [self addSubview:self.undoButton];
    
    UIButton * paintButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.paintButton = paintButton;
    [self.paintButton addTarget:self
                         action:@selector(paintPressed:)
               forControlEvents:UIControlEventTouchDown];
    btnImage = [[ThemeFactory currentTheme] iconForPaintControl];
    [self.paintButton setImage:btnImage
                      forState:UIControlStateNormal];
    self.paintButton.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControlButton];
    self.paintButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.paintButton];
    
    UIButton * eraseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.eraserButton = eraseButton;
    [self.eraserButton addTarget:self
                          action:@selector(eraserPressed:)
                forControlEvents:UIControlEventTouchDown];
    btnImage = [[ThemeFactory currentTheme] iconForEraseControl];
    [self.eraserButton setImage:btnImage
                       forState:UIControlStateNormal];
    self.eraserButton.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControlButton];
    self.eraserButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.eraserButton];
    
    UIButton * clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.clearButton = clearButton;
    self.clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clearButton addTarget:self
                         action:@selector(clearPressed:)
               forControlEvents:UIControlEventTouchDown];
    
    btnImage = [[ThemeFactory currentTheme] iconForClearControl];
    [self.clearButton setImage:btnImage
                      forState:UIControlStateNormal];
    self.clearButton.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControlButton];
    [self addSubview:self.clearButton];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor grayColor];
    lineView.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.dividerLine = lineView;
    self.dividerLine.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:lineView];
    
    NSDictionary * views = NSDictionaryOfVariableBindings(colorView, brushView, slider, undoButton, paintButton, eraseButton, clearButton, lineView);
    
    NSLayoutConstraint * collectionViewHeight = [NSLayoutConstraint constraintWithItem:colorView
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self
                                                                             attribute:NSLayoutAttributeHeight
                                                                            multiplier:0.20
                                                                              constant:0] ;
    
    NSLayoutConstraint * sliderWidth = [NSLayoutConstraint constraintWithItem:slider
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:colorView
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:1.0
                                                                     constant:- 2 * EDGE_OFFSET];
    
    NSLayoutConstraint * sliderHeight = [NSLayoutConstraint constraintWithItem:slider
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:colorView
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:0.6
                                                                      constant:0];
    
    NSLayoutConstraint * brushViewWidth = [NSLayoutConstraint constraintWithItem:brushView
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:colorView
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:0];
    
    NSLayoutConstraint * brushViewHeight = [NSLayoutConstraint constraintWithItem:brushView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:colorView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1.0
                                                                         constant:0];
    
    NSLayoutConstraint * dividerLineX = [NSLayoutConstraint constraintWithItem:lineView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1
                                                                      constant:0];
    
    NSLayoutConstraint * dividerWidth = [NSLayoutConstraint constraintWithItem:lineView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.00
                                                                      constant:0];
    
    NSLayoutConstraint * undoHeight = [NSLayoutConstraint constraintWithItem:undoButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:paintButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0];
    
    NSLayoutConstraint * eraserHeight = [NSLayoutConstraint constraintWithItem:eraseButton
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:paintButton
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0
                                                                      constant:0];
    
    NSLayoutConstraint * clearHeight = [NSLayoutConstraint constraintWithItem:clearButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:paintButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:0];
    
    NSLayoutConstraint * undoSize = [NSLayoutConstraint constraintWithItem:undoButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:paintButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:0];
    
    NSLayoutConstraint * eraserSize = [NSLayoutConstraint constraintWithItem:eraseButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:paintButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0
                                                                    constant:0];
    
    NSLayoutConstraint * clearSize = [NSLayoutConstraint constraintWithItem:clearButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:paintButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:0];
    
    NSDictionary * metrics = @{@"sliderAndColorsDivider":[NSNumber numberWithFloat:DISTANCE_BETWEEN_SLIDER_AND_COLORS],
                               @"edgeOffset": [NSNumber numberWithFloat:EDGE_OFFSET],
                               @"dividerDistance" : [NSNumber numberWithFloat:DISTANCE_BETWEEN_DIVIDER],
                               @"buttonDistance" : [NSNumber numberWithFloat:DISTANCE_BETWEEN_BUTTONS],
                               @"iconSize" : [NSNumber numberWithFloat:ICON_SIZE],
                               @"bottomDividerDistance" : [NSNumber numberWithFloat:DISTANCE_BETWEEN_BOTTOMS_AND_DIVIDER]};
    
    NSString * colorViewConstraintV = @"V:[paintButton(==iconSize)]-bottomDividerDistance-[lineView(==1)]-dividerDistance-[brushView]-dividerDistance-[slider]-sliderAndColorsDivider-[colorView]-0-|";
    //    NSString * colorViewConstraintH = @"H:|-edgeOffset-[brushView]-brushAndCollectionDivider-[colorView]-edgeOffset-|";
    NSString * colorViewConstraintH = @"H:|-0-[colorView]-0-|";
    NSString * brushViewConstraintH = @"H:|-0-[brushView]-0-|";
    NSString * sliderConstraintH = @"H:|-edgeOffset-[slider]-edgeOffset-|";
    NSString * actionButtonsH = @"H:[eraseButton(==iconSize)]-buttonDistance-[undoButton(==iconSize)]-buttonDistance-[paintButton(==iconSize)]-edgeOffset-|";
    NSString * clearButtonH = @"H:|-edgeOffset-[clearButton(==iconSize)]";
    
    [self addConstraints:@[collectionViewHeight,
                           brushViewWidth,
                           brushViewHeight,
                           sliderWidth,
                           sliderHeight,
                           dividerLineX,
                           dividerWidth,
                           undoHeight,
                           clearHeight,
                           eraserHeight,
                           undoSize,
                           clearSize,
                           eraserSize]];
    
    NSArray * allConstraints = @[colorViewConstraintH,
                                 colorViewConstraintV,
                                 sliderConstraintH,
                                 actionButtonsH,
                                 clearButtonH,
                                 brushViewConstraintH];
    
    for (NSString * constraintStr in allConstraints)
    {
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintStr
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
    }
    
}

- (void)sliderValueChanged:(id)sender {
    _currentBrushWidth = self.slider.value;
    self.brushView.lineWidth = _currentBrushWidth;
    if (!self.isInPaintMode && !self.isInEraseMode)
    {
        self.isInPaintMode = YES;
        id<PaintConfigDelegate> temp = self.delegate;
        if (temp)
        {
            [temp paintModeActivated];
            self.paintButton.tintColor = [[ThemeFactory currentTheme] tintColorForActivePaintControlButton];
        }
    }
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
    if (self.isInPaintMode)
    {
        self.isInPaintMode = NO;
        self.paintButton.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControlButton];
    }
    else
    {
        self.isInPaintMode = YES;
        self.paintButton.tintColor = [[ThemeFactory currentTheme] tintColorForActivePaintControlButton];
        
        if (self.isInEraseMode)
        {
            self.isInEraseMode = NO;
            self.eraserButton.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControlButton];
        }
    }
    
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
    if (self.isInEraseMode)
    {
        self.isInEraseMode = NO;
        self.eraserButton.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControlButton];
    }
    else
    {
        self.isInEraseMode = YES;
        self.eraserButton.tintColor = [[ThemeFactory currentTheme] tintColorForActivePaintControlButton];
        if (self.isInPaintMode)
        {
            self.isInPaintMode = NO;
            self.paintButton.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControlButton];
        }
    }
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
        if (!self.isInPaintMode)
        {
            self.isInPaintMode = YES;
            
            if (self.isInEraseMode)
            {
                self.isInEraseMode = NO;
                self.eraserButton.tintColor = [[ThemeFactory currentTheme] tintColorForInactivePaintControlButton];
            }
            id<PaintConfigDelegate> temp = self.delegate;
            if (temp)
            {
                [temp paintModeActivated];
                self.paintButton.tintColor = [[ThemeFactory currentTheme] tintColorForActivePaintControlButton];
            }
        }
    }
}

-(void) redrawSamplePath
{
    [self.brushView redrawSamplePath];
}
@end
