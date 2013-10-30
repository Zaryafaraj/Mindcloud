//
//  PaintbrushViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "PaintbrushViewController.h"
#import "ThemeFactory.h"
#import "BrushSelectionView.h"

@interface PaintbrushViewController ()
@property (weak, nonatomic) IBOutlet UISlider *slider;

@property (weak, nonatomic) IBOutlet BrushSelectionView *brushView;

@end

@implementation PaintbrushViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    self.slider.minimumValue = self.minBrushWidth;
    self.slider.maximumValue = self.maxBrushWidth;
    self.slider.value = self.currentBrushWidth;
    self.brushView.lineWidth = self.currentBrushWidth;
}

-(void) viewWillDisappear:(BOOL)animated
{
    id<PaintbrushDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel brushSelectedWithWidth:self.currentBrushWidth];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
