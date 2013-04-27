//
//  ListsCollectionRowView.m
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "MainScreenRow.h"
#import "ListTableSlideAnimationManager.h"
#import "ThemeFactory.h"
#import "ITheme.h"
#import "ListTableAnimationManager.h"
#import "ListRowSlideAnimationManager.h"
#import <QuartzCore/QuartzCore.h>
#import "SlidingTableRowLayoutManager.h"


#define LABEL_INSET_HOR 10
#define LABEL_INSET_VER 10
#define IMG_INSET_HOR 5
#define IMG_INSET_VER 5
#define IMG_WIDTH 70

@interface MainScreenRow()

@property (strong, nonatomic) UILabel * collectionLabel;
@property (strong, nonatomic) UIImageView * collectionImage;
@property (strong, nonatomic) UIView * backgroundView;
@property (strong, nonatomic) UIButton * shareButton;
@property (strong, nonatomic) UIButton * deleteButton;
@property (strong, nonatomic) UIButton *  renameButton;
@property  BOOL isOpen;

@end
@implementation MainScreenRow

@synthesize index = _index;
@synthesize animationManager = _animationManager;
@synthesize foregroundView = _foregroundView;

-(id) init
{
    self = [super init];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        [self addBackgroundLayer];
        [self addActionButtons];
        [self addforgroundLayer];
        [self addGestureRecognizers];
        self.animationManager = [[ListRowSlideAnimationManager alloc] init];
        self.layoutManager = [[SlidingTableRowLayoutManager alloc] init];
    }
    return self;
}

-(void) setText:(NSString *)text
{
    self.collectionLabel.text = text;
}

-(void) setImage:(UIImage *)image
{
    self.collectionImage.image = image;
}

-(NSString *) text
{
    return self.collectionLabel.text;
}

-(UIImage *) image
{
    return self.collectionImage.image;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self closeView];
    self.foregroundView.frame = [self foregroundFrame];
    self.backgroundView.frame = [self backgroundFrame];
    self.collectionImage.frame = [self imageFrame];
    self.collectionLabel.frame = [self labelFrame];
    NSArray * buttonFrames = [self getActionButtonFrames];
    self.shareButton.frame = [buttonFrames[0] CGRectValue];
    self.renameButton.frame = [buttonFrames[1] CGRectValue];
    self.deleteButton.frame = [buttonFrames[2] CGRectValue];
    [[ThemeFactory currentTheme] stylizeMainscreenRowForeground:self.foregroundView
                                                         isOpen:NO
                                                 withOpenBounds:CGRectZero];
}

-(void) setAlpha:(CGFloat)alpha
{
    //don't invoke super
    //because there are views with alpha zero on top of these
    //[super setAlpha:alpha];
    self.foregroundView.alpha = alpha;
    self.backgroundView.alpha = alpha;
    self.collectionImage.alpha = alpha;
    self.collectionLabel.alpha = alpha;
    self.shareButton.alpha = alpha;
    self.renameButton.alpha = alpha;
    self.deleteButton.alpha = alpha;
}

-(void) swippedLeft:(UISwipeGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded)
    {
        [self closeView];
    }
}

-(void) swippedRight:(UISwipeGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded)
    {
        [self openView];
    }
}

-(void) tapped:(UISwipeGestureRecognizer *) sender
{
}

-(void) openView
{
    if (!self.isOpen)
    {
        self.isOpen = YES;
        CGRect openSize = [self.layoutManager frameForOpenedRow:self.foregroundView];
        [self.animationManager slideOpenMainScreenRow:self.foregroundView
                                    withButtons:@[self.shareButton, self.renameButton, self.deleteButton] toRect:openSize];
        
        [[ThemeFactory currentTheme] stylizeMainscreenRowForeground:self.foregroundView
                                                             isOpen:YES
                                                     withOpenBounds:openSize];
        [self showButtons:YES];
    }
}

-(void) closeView
{
    if (self.isOpen)
    {
        
        self.isOpen = NO;
        [self.animationManager slideCloseMainScreenRow:self.foregroundView
                                           withButtons:@[self.shareButton, self.deleteButton, self.renameButton] withCompletion:^{
            [[ThemeFactory currentTheme] stylizeMainscreenRowForeground:self.foregroundView
                                                                 isOpen:NO
                                                         withOpenBounds:CGRectZero];
                                           }];
        
    }
}

-(void) addforgroundLayer
{
    CGRect foregroundFrame = [self foregroundFrame];
    UIView * foregroundView = [[UIView alloc] initWithFrame:foregroundFrame];
    foregroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:foregroundView];
    self.foregroundView = foregroundView;
    [self addImagePlaceHolder];
    [self addLabelPlaceholder];
    [[ThemeFactory currentTheme] stylizeMainscreenRowForeground:self.foregroundView
                                                         isOpen:NO
                                                 withOpenBounds:CGRectZero];
}

-(CGRect) foregroundFrame
{
    return self.bounds;
}

-(void) addBackgroundLayer
{
    CGRect backgroundFrame = [self backgroundFrame];
    UIView * backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backgroundView];
}

-(CGRect) backgroundFrame
{
    return self.bounds;
}

-(void) sharePressed:(id) sender
{
    [self.delegate sharePressed:self];
}

-(void) deletePressed:(id) sender
{
    [self.delegate deletePressed:self];
}

-(void) renamePressed:(id) sender
{
    [self.delegate renamePressed:self];
}

-(void) addActionButtons
{
    
    NSArray * frames = [self getActionButtonFrames];
    CGRect  addButtonFrame = [frames[0] CGRectValue];
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton addTarget:self
                  action:@selector(sharePressed:)
        forControlEvents:UIControlEventTouchDown];
    UIImage * shareImage = [[ThemeFactory currentTheme] imageForMainScreenRowShareButton];
    [shareButton setBackgroundImage:shareImage forState:UIControlStateNormal];
    //[shareButton setImageEdgeInsets:UIEdgeInsetsZero];
    shareButton.frame = addButtonFrame;
    
    //rename Button
    CGRect renameButtonFrame = [frames[0] CGRectValue];
    UIButton * renameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [renameButton addTarget:self
               action:@selector(renamePressed:)
     forControlEvents:UIControlEventTouchDown];
    UIImage * renameImg = [[ThemeFactory currentTheme] imageForMainscreenRowRenameButton];
    [renameButton setBackgroundImage:renameImg forState:UIControlStateNormal];
    renameButton.frame = renameButtonFrame;
    
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect deleteButtonFrame = [frames[2] CGRectValue];
    [deleteButton addTarget:self
               action:@selector(deletePressed:)
     forControlEvents:UIControlEventTouchDown];
    UIImage * deleteImage = [[ThemeFactory currentTheme] imageForMainScreenRowDeleteButton];
    [deleteButton setBackgroundImage:deleteImage forState:UIControlStateNormal];
    deleteButton.frame = deleteButtonFrame;
    
    self.shareButton = shareButton;
    self.renameButton = renameButton;
    self.deleteButton = deleteButton;
    [[ThemeFactory currentTheme] stylizeMainScreenRowButton:shareButton];
    [[ThemeFactory currentTheme] stylizeMainScreenRowButton:deleteButton];
    [[ThemeFactory currentTheme] stylizeMainScreenRowButton:renameButton];
    [self addSubview:shareButton];
    [self addSubview:renameButton];
    [self addSubview:deleteButton];
    
    [self hideButtons:NO];
}

-(NSArray *) getActionButtonFrames
{
    //add Button
    CGSize buttonSize = CGSizeMake(self.bounds.size.width/9, self.bounds.size.height);
    CGRect addButtonFrame = CGRectMake(self.backgroundView.bounds.origin.x,
                                       self.backgroundView.bounds.origin.y,
                                       buttonSize.width,
                                       buttonSize.height);
    NSValue * addButton = [NSValue valueWithCGRect:addButtonFrame];
    
    CGRect renameButtonFrame = CGRectMake(addButtonFrame.origin.x + addButtonFrame.size.width,
                                          addButtonFrame.origin.y,
                                          addButtonFrame.size.width,
                                          addButtonFrame.size.height);
    
    NSValue * renameButton = [NSValue valueWithCGRect:renameButtonFrame];
    CGRect deleteButtonFrame = CGRectMake(renameButtonFrame.origin.x + renameButtonFrame.size.width,
                                          renameButtonFrame.origin.y,
                                          renameButtonFrame.size.width,
                                          renameButtonFrame.size.height);
    NSValue * deleteButton = [NSValue valueWithCGRect:deleteButtonFrame];
    return @[addButton, renameButton, deleteButton];
}
-(void) hideButtons:(BOOL) animated
{
    self.shareButton.hidden = YES;
    self.renameButton.hidden = YES;
    self.deleteButton.hidden = YES;
}

-(void) showButtons:(BOOL) animated
{
    self.shareButton.hidden = NO;
    self.renameButton.hidden = NO;
    self.deleteButton.hidden = NO;
}

-(void) addLabelPlaceholder
{
    CGRect labelFrame = [self labelFrame];
    UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    
    [self.foregroundView addSubview:label];
    self.collectionLabel = label;
}

-(CGRect) labelFrame
{
    CGSize labelSize = CGSizeMake(self.bounds.size.width - 2 * LABEL_INSET_HOR - self.collectionImage.frame.size.width,
                                  self.bounds.size.height - 2 * LABEL_INSET_VER);
    CGPoint labelOrigin = CGPointMake(self.bounds.origin.x + LABEL_INSET_HOR + self.collectionImage.frame.size.width,
                                      LABEL_INSET_VER);
    CGRect labelFrame = CGRectMake(labelOrigin.x, labelOrigin.y,
                                   labelSize.width, labelSize.height);
    return labelFrame;
}

-(void) addImagePlaceHolder
{
    CGRect imgFrame = [self imageFrame];
    UIImageView * image = [[UIImageView alloc] initWithFrame:imgFrame];
    
    [self.foregroundView addSubview:image];
    self.collectionImage = image;
}

-(CGRect) imageFrame
{
    CGRect imgFrame = CGRectMake(self.bounds.origin.x + IMG_INSET_HOR,
                                 self.bounds.origin.y + IMG_INSET_VER,
                                 IMG_WIDTH,
                                 self.bounds.size.height - 2 * IMG_INSET_VER);
    return imgFrame;
}

-(void) addGestureRecognizers
{
    self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
    UISwipeGestureRecognizer * lsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swippedLeft:)];
    lsgr.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer * rsgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swippedRight:)];
    rsgr.direction = UISwipeGestureRecognizerDirectionRight;
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tgr requireGestureRecognizerToFail:lsgr];
    [tgr requireGestureRecognizerToFail:rsgr];
    [self addGestureRecognizer:lsgr];
    [self addGestureRecognizer:rsgr];
    [self addGestureRecognizer:tgr];
    
}

-(UIView<ListRow> *) prototypeSelf
{
    MainScreenRow * prototype = [[MainScreenRow alloc] init];
    prototype.frame = self.frame;
    prototype.text = self.text;
    prototype.delegate = self.delegate;
    return prototype;
}

-(void) reset
{
    [self closeView];
}

-(NSString *) description
{
    return self.collectionLabel.text;
}

@end
