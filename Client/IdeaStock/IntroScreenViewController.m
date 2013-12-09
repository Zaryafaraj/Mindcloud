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
#define VIEW_OFFSET 75

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
        [self setupHeroPage:view];
    }
    if ( i == 1)
    {
        NSString * title = @"Stay creative and focused";
        NSString * desc = @"Layout your notes and images freely or organize them into stacks.\nHave the freedom to be creative and the organization to be focused.";
        [self setupInfoPage:view
                  withTitle:title
             andDescription:desc
                      split:NO];
    }
    if ( i == 2 )
    {
        NSString * title = @"Express yourself freely";
        NSString * desc = @"Write, sketch, or mark the screen by simply drawing on it.";
        [self setupInfoPage:view
                  withTitle:title
             andDescription:desc
                      split:NO];
        
    }
    if (i == 3)
    {
        NSString * title = @"Collaborate Easily";
        NSString * desc = @"Collaborate with anyone with just two taps.\nEveryone who is collaborating with you sees your changes immediately.";
        [self setupInfoPage:view
                  withTitle:title
             andDescription:desc
                      split:YES];
    }
    return view;
}

-(void) setupHeroPage:(UIView *) page
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

-(void) setupInfoPage:(UIView *) page
            withTitle:(NSString *) title
       andDescription:(NSString *) description
                split:(BOOL) split
{
    UILabel * titleLabel = [[UILabel alloc] init];
    UILabel * descriptionLabel = [[UILabel alloc] init];
    
    titleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    titleLabel.font = [UIFont systemFontOfSize:24];
    titleLabel.text = title;
    titleLabel.shadowColor = [UIColor darkGrayColor];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    descriptionLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    descriptionLabel.font = [UIFont systemFontOfSize:18];
    descriptionLabel.text = description;
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.shadowColor = [UIColor darkGrayColor];
    descriptionLabel.shadowOffset = CGSizeMake(0, 1);
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.numberOfLines = 3;
    
    [page addSubview:titleLabel];
    [page addSubview:descriptionLabel];
    
    NSLayoutConstraint * titleCenterX = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:page
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.f
                                                                      constant:0.f];
    
    NSLayoutConstraint * descriptionCenterX = [NSLayoutConstraint constraintWithItem:descriptionLabel
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:page
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.f
                                                                            constant:0.f];
    
    
    NSLayoutConstraint * titlePosY = [NSLayoutConstraint constraintWithItem:titleLabel
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:page
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.5
                                                                   constant:0.f];
    NSArray * constraints = @[titleCenterX, descriptionCenterX, titlePosY];
    [page addConstraints:constraints];
    
    NSDictionary * titleViews = NSDictionaryOfVariableBindings(titleLabel, descriptionLabel);
    NSString * titleConstraints = @"V:[titleLabel]-30-[descriptionLabel]";
    [page addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:titleConstraints
                                                                 options:0
                                                                 metrics:nil
                                                                   views:titleViews]];
    
    UIScrollView * scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [page addSubview:scrollView];
    
    
    NSDictionary * scrollViewDict = NSDictionaryOfVariableBindings(scrollView, titleLabel);
    
    NSString * scrollViewConstraintV = @"V:[scrollView]-50-[titleLabel]";
    [page addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:scrollViewConstraintV
                                                                 options:0
                                                                 metrics:nil
                                                                   views:scrollViewDict]];
    if (split)
    {
        UIScrollView * scrollView2 = [[UIScrollView alloc] init];
        scrollView2.backgroundColor = [UIColor whiteColor];
        scrollView2.showsHorizontalScrollIndicator = NO;
        scrollView2.showsVerticalScrollIndicator = NO;
        scrollView2.translatesAutoresizingMaskIntoConstraints = NO;
        [page addSubview:scrollView2];
        
        NSDictionary * scrollViewDict2 = NSDictionaryOfVariableBindings(scrollView2, scrollView, titleLabel);
        
        NSString * scrollViewConstraintV2 = @"V:[scrollView2]-50-[titleLabel]";
        [page addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:scrollViewConstraintV2
                                                                     options:0
                                                                     metrics:nil
                                                                       views:scrollViewDict2]];
        
        
        NSString * scrollViewConstraintH = @"H:|-50-[scrollView]-20-[scrollView2]-50-|";
        [page addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:scrollViewConstraintH
                                                                     options:0
                                                                     metrics:nil
                                                                       views:scrollViewDict2]];
        
        NSString * scrollViewConstraintTop = @"V:|-(>=75,<=200)-[scrollView]";
        [page addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:scrollViewConstraintTop
                                                                     options:0
                                                                     metrics:nil
                                                                       views:scrollViewDict2]];
//        NSString * scrollViewWidthConstraint = @"[scrollView(==300)]";
//        [page addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:scrollViewWidthConstraint
//                                                                     options:0
//                                                                     metrics:nil
//                                                                       views:scrollViewDict2]];
        
        NSLayoutConstraint * scrollViewEqualWidth = [NSLayoutConstraint constraintWithItem:scrollView
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:scrollView2
                                                                                 attribute:NSLayoutAttributeWidth
                                                                                multiplier:1.f
                                                                                  constant:0.f];
        
        NSLayoutConstraint * scrollViewHeight = [NSLayoutConstraint constraintWithItem:scrollView2
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationLessThanOrEqual
                                                                                toItem:scrollView2
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:1.3
                                                                              constant:0.f];
        
        NSLayoutConstraint * scrollViewEqualHeight = [NSLayoutConstraint constraintWithItem:scrollView
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                  relatedBy:NSLayoutRelationEqual
                                                                                     toItem:scrollView2
                                                                                  attribute:NSLayoutAttributeHeight
                                                                                 multiplier:1.f
                                                                                   constant:0.f];
        NSArray * scrollViewConstraints = @[scrollViewEqualHeight, scrollViewEqualWidth, scrollViewHeight];
        
        [page addConstraints:scrollViewConstraints];
        
    }
    else
    {
        NSLayoutConstraint * scrollViewPosX = [NSLayoutConstraint constraintWithItem:scrollView
                                                                           attribute:NSLayoutAttributeCenterX
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:page
                                                                           attribute:NSLayoutAttributeCenterX
                                                                          multiplier:1.0
                                                                            constant:0.f];
        
        NSLayoutConstraint * scrollViewHeight = [NSLayoutConstraint constraintWithItem:scrollView
                                                                             attribute:NSLayoutAttributeHeight
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:scrollView
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:0.75
                                                                              constant:0.f];
        
        NSArray * scrollViewConstraints = @[scrollViewPosX, scrollViewHeight];
        
        
        NSString * scrollViewWidthConstraint = @"[scrollView(==550)]";
        [page addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:scrollViewWidthConstraint
                                                                     options:0
                                                                     metrics:nil
                                                                       views:scrollViewDict]];
        
        [page addConstraints:scrollViewConstraints];
    }
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
