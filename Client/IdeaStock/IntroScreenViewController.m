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
//indexed on page number starting from 0
@property (strong, nonatomic) NSMutableDictionary * pageViews;
@property (weak, nonatomic) IBOutlet UIView *container;
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

#define NUMBER_OF_PAGES 5
#define VIEW_OFFSET 150

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pageControl.numberOfPages = NUMBER_OF_PAGES;
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.pageViews = [NSMutableDictionary dictionary];
    self.scrollView.backgroundColor = [[ThemeFactory currentTheme] tintColor];
    self.scrollView.delegate = self;
    UIView * contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:contentView];
    
    [self setScrollViewContent:contentView];
    
    [self setContentView:contentView];
}


-(void) setContentView:(UIView *) contentView
{
    
    NSMutableArray * array = [NSMutableArray array];
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSString * constraint = @"H:|-0-";
    for (int i = 0 ; i < NUMBER_OF_PAGES; i++)
    {
        UIView * result = [self setPageContent: contentView withPageNumber:i];
        [dict setObject:result
                 forKey:[NSString stringWithFormat:@"view%d", i]];
        result.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:result];
        NSNumber * index = [NSNumber numberWithInt:i];
        [self.pageViews setObject:result
                           forKey:index];
        
        CGFloat numOfPage = NUMBER_OF_PAGES;
        NSLayoutConstraint * widthConstraint = [NSLayoutConstraint constraintWithItem:result
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:contentView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1/numOfPage
                                                                             constant:0];
        
        NSLayoutConstraint * heightConstraint = [NSLayoutConstraint constraintWithItem:result
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:contentView
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1
                                                                             constant:0];
        NSDictionary * viewBindings = NSDictionaryOfVariableBindings(result);
        NSString * originContrainst = @"V:|[result]|";
        NSArray * originConstraints = [NSLayoutConstraint constraintsWithVisualFormat:originContrainst
                                                options:0 metrics:nil
                                                  views:viewBindings];
        [array addObject: widthConstraint];
        [array addObject: heightConstraint];
        [array addObjectsFromArray:originConstraints];
        constraint = [constraint stringByAppendingString:[NSString stringWithFormat:@"[view%d]", i]];
    }
    
    //for some reason auto layout messes up when we add this constraint
    //constraint = [constraint stringByAppendingString:@"|"];
    [contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:constraint
                                                                                     options:0
                                                                                     metrics:nil
                                                                               views:dict]];
    [contentView addConstraints:array];
}

-(UIView *) setPageContent:(UIView *) contentView
        withPageNumber:(int) i
{
    
    UIColor * color = [UIColor clearColor];
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = color;
    if( i == 0)
    {
         [self setupPage0:view];
    }
    return view;
}

-(void) setupPage0:(UIView *) page
{
    NSString * heroTitle = @"Mindcloud";
    NSString * heroDescription = @"Think, Brainstorm, Collaborate";
    NSString * instruction = @"Swipe to learn more";
    UILabel * heroTitleLabel = [[UILabel alloc] init];
    UILabel * heroDescriptionLabel = [[UILabel alloc] init];
    UILabel * instructionLabel = [[UILabel alloc] init];
    heroTitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1];
    heroTitleLabel.font = [UIFont systemFontOfSize:120];
    heroDescriptionLabel.textColor = heroTitleLabel.textColor;
    heroDescriptionLabel.font = [UIFont systemFontOfSize:23];
    instructionLabel.textColor = heroTitleLabel.textColor;
    instructionLabel.font = [UIFont systemFontOfSize:20];
    
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : heroTitleLabel.textColor,
                             NSFontAttributeName : heroTitleLabel.font,
                             NSTextEffectAttributeName : NSTextEffectLetterpressStyle};
    
    
    NSAttributedString* attrString = [[NSAttributedString alloc]
                                      initWithString: heroTitle
                                      attributes:attrs];
    
    heroTitleLabel.attributedText = attrString;
    heroTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    heroDescriptionLabel.text = heroDescription;
    heroDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    heroDescriptionLabel.shadowColor = [UIColor darkGrayColor];
    heroDescriptionLabel.shadowOffset = CGSizeMake(0, 1);
    instructionLabel.text = instruction;
    instructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    instructionLabel.shadowColor = [UIColor darkGrayColor];
    instructionLabel.shadowOffset = CGSizeMake(0, 1);
    
    [page addSubview:heroTitleLabel];
    [page addSubview:heroDescriptionLabel];
    [page addSubview:instructionLabel];
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:heroTitleLabel
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:page
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.f
                                                                    constant:0.f];
    
    NSLayoutConstraint * constraint2 = [NSLayoutConstraint constraintWithItem:heroTitleLabel
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:page
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.f
                                                                     constant:0.f];
    
    NSLayoutConstraint * constraint3 = [NSLayoutConstraint constraintWithItem:heroDescriptionLabel
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:page
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.f
                                                                     constant:0.f];
    
    NSLayoutConstraint * constraint4 = [NSLayoutConstraint constraintWithItem:instructionLabel
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:page
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.f
                                                                     constant:+650.f];
    [page addConstraint:constraint];
    [page addConstraint:constraint2];
    [page addConstraint:constraint3];
    [page addConstraint:constraint4];
    
    NSDictionary * heroViews = NSDictionaryOfVariableBindings(heroTitleLabel, heroDescriptionLabel);
    NSString * heroConstraint = @"V:[heroTitleLabel]-30-[heroDescriptionLabel]";
    [page addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heroConstraint
                                                                 options:0
                                                                 metrics:nil
                                                                   views:heroViews]];
    
    NSDictionary * instructionViews = NSDictionaryOfVariableBindings(heroDescriptionLabel, instructionLabel);
    NSString * instructionConstraint = @"V:[heroDescriptionLabel]-150-[instructionLabel]";
    [page addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:instructionConstraint
                                                                 options:0
                                                                 metrics:nil
                                                                   views:instructionViews]];
    
    //wait for 0.7 for current layout to settle in then animate a change
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [UIView animateWithDuration:1.0
                              delay:0.7
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             //move the heros 100 up and move the instruction to the center
                             constraint.constant = -100;
                             [page layoutIfNeeded];
                         }completion:^(BOOL completed){
                         }];
        
        [UIView animateWithDuration:1.1
                              delay:0.8
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             
            constraint4.constant = 0;
            [page layoutIfNeeded];
                         }completion:^(BOOL completed){
                         }];
        
    });
}

-(void) setScrollViewContent:(UIView *) contentView
{
    
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


-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    [self dismissSelfIfNeccessary];
}

-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
    [self dismissSelfIfNeccessary];
}

-(void) dismissSelfIfNeccessary
{
    NSInteger newPageIndex = (self.scrollView.contentOffset.x + self.scrollView.bounds.size.width/2)/self.scrollView.frame.size.width;
    
    NSLog(@"fff - %d" , newPageIndex);
}
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    int pageNo = self.pageControl.currentPage;
    CGFloat xOffset = pageNo * self.scrollView.frame.size.width;
    
    self.scrollView.contentOffset = CGPointMake(xOffset, self.scrollView.contentOffset.y);
}


- (IBAction)skipPressed:(id)sender
{
    if (self.delegate)
    {
        id<IntroScreenDelegate> temp = self.delegate;
        [temp introScreenFinished:YES];
    }
}

- (IBAction)signinPressed:(id)sender
{
    if (self.delegate)
    {
        id<IntroScreenDelegate> temp = self.delegate;
        [temp signInPressed];
    }
}

@end
