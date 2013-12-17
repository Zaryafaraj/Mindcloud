//
//  IntroScreenViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/6/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "IntroScreenViewController.h"
#import "ThemeFactory.h"
#import "NoteView.h"
#import "ImageNoteView.h"
#import "DrawingTraceContainer.h"
#import "FileSystemHelper.h"
#import "TutorialPaintView.h"

@interface IntroScreenViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
//indexed on page number starting from 0
@property (strong, nonatomic) NSMutableDictionary * pageViews;
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@property (weak, nonatomic) IBOutlet UIButton *signinButton;
@property (weak, nonatomic) IBOutlet NoteView *prototypeNote;

@property (weak, nonatomic) IBOutlet ImageNoteView *prototypeImageNote;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *skipConstraint1;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *skipConstraint2;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *signinConstraint1;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *signinConstraint2;

@property (nonatomic) int lastPage;
@property (nonatomic) BOOL lastPagehasFinalLayout;
@property (nonatomic) BOOL lastPageStartLayoutAnimationInProgress;
@property (nonatomic) BOOL lastPageResetLayoutAnimationInProgress;
//because sometimes scrolling happens because of rotation to fix content offset
//and we start some animations based on scrolling, we set this flag when the scrolling
//happens so that we don't animate stuff when user has not scrolled himself
@property (nonatomic) BOOL rotationCausedScrolling;
@property (nonatomic, strong) NSArray * endButtonConstraints;
//for detecting scroll direction
@property (nonatomic, assign) NSInteger lastContentOffset;
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
#define PAGE1_DRAWING_FILEPATH @"introPath1"
#define DRAWING_FILE_TYPE @"pth"
- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    [super viewDidLoad];
    
    self.lastPage = -1;
    self.pageControl.numberOfPages = NUMBER_OF_PAGES;
    self.pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.pageViews = [NSMutableDictionary dictionary];
    self.scrollView.backgroundColor = [[ThemeFactory currentTheme] tintColor];
    self.scrollView.delegate = self;
    UIView * contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor clearColor];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView insertSubview:contentView belowSubview:self.skipButton];
    
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
                 withPageNo:i
                  withTitle:title
             andDescription:desc
                      split:NO];
    }
    if ( i == 2 )
    {
        NSString * title = @"Express yourself freely";
        NSString * desc = @"Write, sketch, or mark the screen by simply drawing on it.";
        [self setupInfoPage:view
                 withPageNo:i
                  withTitle:title
             andDescription:desc
                      split:NO];
        
    }
    if (i == 3)
    {
        NSString * title = @"Collaborate Easily";
        NSString * desc = @"Collaborate with anyone with just two taps.\nEveryone who is collaborating with you sees your changes immediately.";
        [self setupInfoPage:view
                 withPageNo:i
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
           withPageNo:(int) pageNo
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
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.bounces = NO;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    if (pageNo == 2)
    {
        
        scrollView.showsHorizontalScrollIndicator = YES;
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.bounces = NO;
        NSString * filePath = [[NSBundle mainBundle] pathForResource:PAGE1_DRAWING_FILEPATH ofType:DRAWING_FILE_TYPE];
        DrawingTraceContainer * drawingContainer = [DrawingTraceContainer containerWithTheContentsOfTheFile:filePath];
        TutorialPaintView * paintView = [[TutorialPaintView alloc] initWithContainer:drawingContainer];
        paintView.backgroundColor = [UIColor greenColor];
        paintView.translatesAutoresizingMaskIntoConstraints = NO;
        [scrollView addSubview:paintView];
        
        NSLayoutConstraint * paintViewWidth = [NSLayoutConstraint constraintWithItem:paintView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:scrollView
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:4
                                                                            constant:1];
        
        NSLayoutConstraint * paintViewHeigth = [NSLayoutConstraint constraintWithItem:paintView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:scrollView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:4
                                                                            constant:1];
        NSArray * paintViewConstraints = @[paintViewWidth, paintViewHeigth];
        NSString * paintViewConstraintH = @"H:|-0-[paintView]-0-|";
        NSString * paintViewConstraintV = @"V:|-0-[paintView]-0-|";
        NSDictionary * paintDict = NSDictionaryOfVariableBindings(paintView);
        [scrollView addConstraints:paintViewConstraints];
        [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:paintViewConstraintH
                                                                           options:0
                                                                           metrics:nil
                                                                             views:paintDict]];
        
        [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:paintViewConstraintV
                                                                           options:0
                                                                           metrics:nil
                                                                             views:paintDict]];
    }
    
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


-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.pageControl.currentPage == 4 && !self.rotationCausedScrolling)
    {
        CGFloat pageWidth = self.scrollView.frame.size.width;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        if (page == 3)
        {
                [self animatePage4:NO];
        }
    }
    
    if (self.pageControl.currentPage == 1 && !self.rotationCausedScrolling)
    {
        CGPoint contentOffset = scrollView.contentOffset;
        [self parallexPage:1 withParentContentOffset:contentOffset];
    }
    if (self.rotationCausedScrolling)
    {
        self.rotationCausedScrolling = NO;
    }
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.pageControl.currentPage != page ||
        (self.pageControl.currentPage == page && page ==4 && !self.lastPagehasFinalLayout))
    {
        self.lastPage = self.pageControl.currentPage;
        self.pageControl.currentPage = page;
        [self dismissSelfIfNeccessary];
    }
}

-(void) dismissSelfIfNeccessary
{
    NSInteger newPageIndex = (self.scrollView.contentOffset.x + self.scrollView.bounds.size.width/2)/self.scrollView.frame.size.width;
    [self pageAppearedAtIndex:newPageIndex];
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.rotationCausedScrolling= YES;
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration
{
    int pageNo = self.pageControl.currentPage;
    CGFloat xOffset = pageNo * self.scrollView.frame.size.width;
    
    self.scrollView.contentOffset = CGPointMake(xOffset, self.scrollView.contentOffset.y);
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.scrollView.superview layoutIfNeeded];
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

-(void) pageAppearedAtIndex:(NSInteger) index
{
    switch (index) {
        case 1:
            [self animatePage1];
            break;
            
        case 2:
            [self animatePage2];
            break;
            
        case 3:
            [self animatePage3];
            if (self.lastPage == 4)
            {
//                [self animatePage4:NO];
            }
            break;
            
        case 4:
            [self animatePage4:YES];
            break;
            
        default:
            break;
    }
}

-(void) animatePage1
{
    
    //run animations only once
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NoteView * noteView = [self.prototypeNote prototype];
        noteView.alpha = 1;
        noteView.text = @"You can quickly add notes to capture ideas";
        
        NoteView * stackNote2 = [self.prototypeNote prototype];
        stackNote2.alpha = 1;
        stackNote2.text = @"Stacks provide an organized view into your notes";
        
        NoteView * stackNote3 = [self.prototypeNote prototype];
        stackNote3.alpha = 1;
        stackNote3.text = @"Everything can be moved around anywhere on the screen";
        
        ImageNoteView * imageNoteView = [self.prototypeImageNote prototype];
        imageNoteView.alpha = 1;
        UIImage * image = [UIImage imageNamed:@"board"];
        imageNoteView.resizesToFitImage = NO;
        imageNoteView.image = image;
        
        NSNumber * number = [NSNumber numberWithInt:1];
        UIView * page = self.pageViews[number];
        if (page)
        {
            UIScrollView * scrollView;
            for(UIView * view in page.subviews)
            {
                if ([view isKindOfClass:[UIScrollView class]])
                {
                    scrollView = (UIScrollView *) view;
                }
            }
            if (scrollView == nil)
            {
                return ;
            }
            
            [scrollView addSubview:noteView];
            [scrollView addSubview:imageNoteView];
            [scrollView addSubview:stackNote2];
            [scrollView addSubview:stackNote3];
            
            imageNoteView.translatesAutoresizingMaskIntoConstraints = NO;
            noteView.translatesAutoresizingMaskIntoConstraints = NO;
            page.translatesAutoresizingMaskIntoConstraints = NO;
            stackNote2.translatesAutoresizingMaskIntoConstraints = NO;
            stackNote3.translatesAutoresizingMaskIntoConstraints = NO;
            
            NSLayoutConstraint * noteCenterX = [NSLayoutConstraint constraintWithItem:noteView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:scrollView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:0.60
                                                                             constant:0];
            
            
            NSLayoutConstraint * noteCenterY = [NSLayoutConstraint constraintWithItem:noteView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:scrollView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:0.60
                                                                             constant:0];
            
            NSLayoutConstraint * stackNoteCenterX = [NSLayoutConstraint constraintWithItem:stackNote3
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:scrollView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.5
                                                                             constant:0];
            
            NSLayoutConstraint * stackNoteCenterY = [NSLayoutConstraint constraintWithItem:stackNote3
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:scrollView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1.4
                                                                             constant:0];
            
            NSLayoutConstraint * stackNote2CenterX = [NSLayoutConstraint constraintWithItem:stackNote2
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:scrollView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.5
                                                                             constant:+17];
            
            NSLayoutConstraint * stackNote2CenterY = [NSLayoutConstraint constraintWithItem:stackNote2
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:scrollView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1.4
                                                                             constant:-185];
            
            
            NSDictionary * viewDicts = NSDictionaryOfVariableBindings(imageNoteView, noteView, stackNote2, stackNote3);
            NSString * noteWidth = @"H:[noteView(==233)]";
            NSString * noteHeight = @"V:[noteView(==165)]";
            NSString * imageWidth = @"H:[imageNoteView(==233)]";
            NSString * imageHeight = @"V:[imageNoteView(==165)]";
            NSString * stackNote2Width = @"H:[stackNote2(==233)]";
            NSString * stackNote2Height = @"V:[stackNote2(==165)]";
            NSString * stackNote3Width = @"H:[stackNote3(==233)]";
            NSString * stackNote3Height = @"V:[stackNote3(==165)]";
            
            NSString * imageConstraintH = @"H:[noteView]-(-270)-[imageNoteView]";
            NSString * imageConstraintV = @"V:[noteView]-(-40)-[imageNoteView]";
            
            NSArray * constraints = @[noteCenterX, noteCenterY, stackNoteCenterX, stackNoteCenterY,
                                      stackNote2CenterX, stackNote2CenterY, stackNoteCenterX, stackNoteCenterY];
            [scrollView addConstraints:constraints];
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:noteWidth
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDicts]];
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:noteHeight
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDicts]];
            
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:imageHeight
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDicts]];
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:imageWidth
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDicts]];
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:imageConstraintH
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDicts]];
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:imageConstraintV
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDicts]];
            
            
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:stackNote2Width
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDicts]];
            
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:stackNote2Height
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewDicts]];
            
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:stackNote3Width
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDicts]];
            
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:stackNote3Height
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:viewDicts]];
            
            
            noteView.transform = CGAffineTransformScale(noteView.transform, 0.1, 0.1);
            imageNoteView.transform = CGAffineTransformScale(imageNoteView.transform, 0.1, 0.1);
            stackNote2.transform = CGAffineTransformScale(stackNote2.transform, 0.1, 0.1);
            stackNote3.transform = CGAffineTransformScale(stackNote3.transform, 0.1, 0.1);
            [UIView animateWithDuration:0.6
                                  delay:0.0
                 usingSpringWithDamping:0.4
                  initialSpringVelocity:2.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 noteView.transform = CGAffineTransformScale(noteView.transform, 10, 10);
                                 stackNote2.transform = CGAffineTransformScale(stackNote2.transform, 10, 10);
                                 stackNote3.transform = CGAffineTransformScale(stackNote3.transform, 8, 8);
                                 imageNoteView.transform = CGAffineTransformScale(imageNoteView.transform, 12, 12);
                             }completion:^(BOOL completed){
                                 [UIView animateWithDuration:1.0
                                                       delay:0.5
                                                     options:UIViewAnimationOptionCurveEaseIn
                                                  animations:^{
                                                      stackNote2CenterX.constant = 0;
                                                      stackNote2CenterY.constant = -90;
                                                      stackNoteCenterY.constant = -90;
                                                      stackNote3.transform = CGAffineTransformIdentity;
                                                      stackNote2.transform = CGAffineTransformRotate(stackNote2.transform, M_PI_4 * 1/8);
                                                      [self.scrollView layoutIfNeeded];
                                                  }completion:^(BOOL finished){
                                                      
                                                      [UIView animateWithDuration:0.7
                                                                            delay:0.5
                                                                          options:UIViewAnimationOptionCurveEaseIn
                                                                       animations:^{
                                                                           CGAffineTransform scale = CGAffineTransformScale(imageNoteView.transform, 0.95, 0.95);
                                                                           imageNoteView.transform = CGAffineTransformTranslate(scale, 50, -20);
                                                                       }completion:^(BOOL finished){
                                                                           
                                                                       }];
                                                      
                                                  }];
                             }];
            
        }
        
    });
}

-(void) animatePage2
{
}

-(void) animatePage3
{
    
    NSLog(@"Animate Page 3");
}

-(void) animatePage4:(BOOL) entered
{
    
    //to make sure we don't double animate when two scrolling events are sent
    if (entered && !self.lastPagehasFinalLayout)
    {
        
        
        NSLayoutConstraint * newSigninConstraintY = [NSLayoutConstraint constraintWithItem:self.signinButton
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:self.signinButton.superview
                                                                                 attribute:NSLayoutAttributeCenterY
                                                                                multiplier:1.0
                                                                                  constant:-50.f];
        
        NSLayoutConstraint * newSkipConstraintY = [NSLayoutConstraint constraintWithItem:self.skipButton
                                                                               attribute:NSLayoutAttributeCenterY
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.skipButton.superview
                                                                               attribute:NSLayoutAttributeCenterY
                                                                              multiplier:1.0
                                                                                constant:+50.f];
        
        NSLayoutConstraint * xConstraintsSignIn = [NSLayoutConstraint constraintWithItem:self.signinButton
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.pageControl
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1
                                                                              constant:0];
        
        NSLayoutConstraint * xConstraintsSkip = [NSLayoutConstraint constraintWithItem:self.skipButton
                                                                               attribute:NSLayoutAttributeCenterX
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.pageControl
                                                                               attribute:NSLayoutAttributeCenterX
                                                                              multiplier:1
                                                                                constant:0];
        NSArray * endButtonConstraints = @[newSkipConstraintY, newSigninConstraintY, xConstraintsSignIn, xConstraintsSkip];
        self.endButtonConstraints = endButtonConstraints;
        [self.skipButton.superview addConstraints:endButtonConstraints];
        
        if (self.lastPageStartLayoutAnimationInProgress) return;
        
        [UIView animateWithDuration:1.0
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.lastPageStartLayoutAnimationInProgress = YES;
                             [self.container.superview layoutIfNeeded];
                         }completion:^(BOOL completed){
                             self.lastPageStartLayoutAnimationInProgress = NO;
                             self.lastPagehasFinalLayout = YES;
                         }];
        
    }
    else
    {
        
        [self.container.superview layoutIfNeeded];
        if (self.lastPageResetLayoutAnimationInProgress) return;
        for (NSLayoutConstraint * constraint in self.endButtonConstraints)
        {
            [self.skipButton.superview removeConstraint:constraint];
        }
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.lastPageResetLayoutAnimationInProgress = YES;
                             [self.skipButton.superview layoutIfNeeded];
                             
                         }completion:^(BOOL completed){
                             self.lastPageResetLayoutAnimationInProgress = NO;
                             self.lastPagehasFinalLayout = NO;
                         }];
    }
}

-(void) parallexPage:(int) pageNo
withParentContentOffset:(CGPoint) contentOffset
{
    NSNumber * number = [NSNumber numberWithInt:pageNo];
    UIView * page = self.pageViews[number];
    if (page)
    {
        UIScrollView * scrollView;
        for(UIView * view in page.subviews)
        {
            if ([view isKindOfClass:[UIScrollView class]])
            {
                scrollView = (UIScrollView *) view;
            }
        }
        if (scrollView == nil)
        {
            return ;
        }
        
        CGFloat percentageMoved = contentOffset.x / (page.bounds.size.width * (pageNo+1));
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x * percentageMoved, scrollView.contentOffset.y);
        
    }
}

@end
