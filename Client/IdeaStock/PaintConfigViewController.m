//
//  PaintConfigViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "PaintConfigViewController.h"
#import "PaintConfigView.h"

@interface PaintConfigViewController ()

@end

@implementation PaintConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    if(self = [super init])
    {
        self.view = [[PaintConfigView alloc] init];
    }
    
    return self;
}

-(UIColor *) currentColor
{
    return ((PaintConfigView *)self.view).selectedColor;
}

-(void) setCurrentColor:(UIColor *)currentColor
{
    ((PaintConfigView *)self.view).selectedColor = currentColor;
}

-(CGFloat) currentWidth
{
    return ((PaintConfigView *)self.view).currentBrushWidth;
}

-(void) setCurrentWidth:(CGFloat)currentWidth
{
    ((PaintConfigView *)self.view).currentBrushWidth = currentWidth;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

-(void) viewDidLayoutSubviews
{
    [((PaintConfigView *)self.view) redrawSamplePath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
