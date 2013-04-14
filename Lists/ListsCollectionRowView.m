//
//  ListsCollectionRowView.m
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "ListsCollectionRowView.h"
#import "AnimationHelper.h"
#import "ThemeFactory.h"
#import "ITheme.h"

#define LABEL_INSET_HOR 10
#define LABEL_INSET_VER 10
#define IMG_INSET_HOR 5
#define IMG_INSET_VER 5
#define IMG_WIDTH 70

@interface ListsCollectionRowView()

@property (strong, nonatomic) UIView * foregroundView;
@property (strong, nonatomic) UIView * backgroundView;
@property (strong, nonatomic) UIButton * shareButton;
@property (strong, nonatomic) UIButton * deleteButton;
@property (strong, nonatomic) UIButton *  renameButton;
@property  BOOL isOpen;

@end
@implementation ListsCollectionRowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        [self addBackgroundLayer];
        [self addActionButtons];
        [self addforgroundLayer];
        [self addGestureRecognizers];
    }
    return self;
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
        [[ThemeFactory currentTheme] stylizeMainscreenRowForeground:self.foregroundView
                                                             isOpen:YES];
        [AnimationHelper slideOpenMainScreenRow:self.foregroundView
                                    withButtons:@[self.shareButton, self.renameButton, self.deleteButton]];
        [self showButtons:YES];
        self.isOpen = YES;
    }
}

-(void) closeView
{
    if (self.isOpen)
    {
        
        [[ThemeFactory currentTheme] stylizeMainscreenRowForeground:self.foregroundView
                                                             isOpen:NO];
        [AnimationHelper slideCloseMainScreenRow:self.foregroundView
                                     withButtons:@[self.shareButton, self.deleteButton, self.renameButton]];
        self.isOpen = NO;
    }
}

-(void) addforgroundLayer
{
    CGRect foregroundFrame = self.bounds;
    UIView * foregroundView = [[UIView alloc] initWithFrame:foregroundFrame];
    foregroundView.backgroundColor = [UIColor whiteColor];
    foregroundView = [[ThemeFactory currentTheme] stylizeMainscreenRowForeground:foregroundView isOpen:NO];
    [self addSubview:foregroundView];
    self.foregroundView = foregroundView;
    [self addImagePlaceHolder];
    [self addLabelPlaceholder];
}

-(void) addBackgroundLayer
{
    CGRect backgroundFrame = self.bounds;
    UIView * backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backgroundView];
}

-(void) sharePressed:(id) sender
{
    NSLog(@"Add");
}

-(void) deletePressed:(id) sender
{
    NSLog(@"Delete");
}

-(void) renamePressed:(id) sender
{
    NSLog(@"Rename");
}

-(void) addActionButtons
{
    CGSize buttonSize = CGSizeMake(self.bounds.size.width/9, self.bounds.size.height);
    
    //add Button
    CGRect addButtonFrame = CGRectMake(self.backgroundView.bounds.origin.x,
                                       self.backgroundView.bounds.origin.y,
                                       buttonSize.width,
                                       buttonSize.height);
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [shareButton addTarget:self
                  action:@selector(sharePressed:)
        forControlEvents:UIControlEventTouchDown];
    UIImage * shareImage = [[ThemeFactory currentTheme] imageForMainScreenRowShareButton];
    [shareButton setBackgroundImage:shareImage forState:UIControlStateNormal];
    //[shareButton setImageEdgeInsets:UIEdgeInsetsZero];
    shareButton.frame = addButtonFrame;
    
    CGRect renameButtonFrame = CGRectMake(addButtonFrame.origin.x + addButtonFrame.size.width,
                                          addButtonFrame.origin.y,
                                          addButtonFrame.size.width,
                                          addButtonFrame.size.height);
    //rename Button
    UIButton * renameButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [renameButton addTarget:self
               action:@selector(renamePressed:)
     forControlEvents:UIControlEventTouchDown];
    UIImage * renameImg = [[ThemeFactory currentTheme] imageForMainscreenRowRenameButton];
    [renameButton setBackgroundImage:renameImg forState:UIControlStateNormal];
    renameButton.frame = renameButtonFrame;
    
    //delete button
    CGRect deleteButtonRect = CGRectMake(renameButtonFrame.origin.x + renameButtonFrame.size.width,
                                          renameButtonFrame.origin.y,
                                          renameButtonFrame.size.width,
                                          renameButtonFrame.size.height);
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteButton addTarget:self
               action:@selector(deletePressed:)
     forControlEvents:UIControlEventTouchDown];
    UIImage * deleteImage = [[ThemeFactory currentTheme] imageForMainScreenRowDeleteButton];
    [deleteButton setBackgroundImage:deleteImage forState:UIControlStateNormal];
    deleteButton.frame = deleteButtonRect;
    
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
    CGSize labelSize = CGSizeMake(self.bounds.size.width - 2 * LABEL_INSET_HOR - self.collectionImage.frame.size.width,
                                  self.bounds.size.height - 2 * LABEL_INSET_VER);
    CGPoint labelOrigin = CGPointMake(self.bounds.origin.x + LABEL_INSET_HOR + self.collectionImage.frame.size.width,
                                      LABEL_INSET_VER);
    CGRect labelFrame = CGRectMake(labelOrigin.x, labelOrigin.y,
                                   labelSize.width, labelSize.height);
    UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    
    [self.foregroundView addSubview:label];
    self.collectionLabel = label;
}

-(void) addImagePlaceHolder
{
    CGRect imgFrame = CGRectMake(self.bounds.origin.x + IMG_INSET_HOR,
                                 self.bounds.origin.y + IMG_INSET_VER,
                                 IMG_WIDTH,
                                 self.bounds.size.height - 2 * IMG_INSET_VER);
    
    UIImageView * image = [[UIImageView alloc] initWithFrame:imgFrame];
    
    [self.foregroundView addSubview:image];
    self.collectionImage = image;
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

-(void) reset
{
    [self closeView];
}
@end
