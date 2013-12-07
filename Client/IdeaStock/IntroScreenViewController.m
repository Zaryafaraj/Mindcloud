//
//  IntroScreenViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/6/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "IntroScreenViewController.h"
#import "ThemeFactory.h"

@interface IntroScreenViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation IntroScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define NUMBER_OF_PAGES 4
#define VIEW_OFFSET 150
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.backgroundColor = [[ThemeFactory currentTheme] tintColor];
    self.scrollView.delegate = self;
    UIView * contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:contentView];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
    label.text = @"HI";
    [contentView addSubview:label];
    NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:contentView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.scrollView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:NUMBER_OF_PAGES
                                                                    constant:0];
    NSLayoutConstraint * heightConstraints = [NSLayoutConstraint constraintWithItem:contentView
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.scrollView
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:1
                                                                           constant: -VIEW_OFFSET];
    
    NSString * hc = @"H:|[contentView]|";
    NSString * vc = @"V:|[contentView]|";
    NSDictionary * views = NSDictionaryOfVariableBindings(contentView);
    [self.scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:hc
                                                                                     options:0
                                                                                     metrics:nil
                                                                               views:views]];
    
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vc
                                                                                   options:0
                                                                                   metrics:nil
                                                                              views:views]];
    [self.scrollView addConstraints:@[heightConstraints, widthConstraint]];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"HI");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

@end
