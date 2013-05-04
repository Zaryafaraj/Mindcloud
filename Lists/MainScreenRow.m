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
@property (strong, nonatomic) UITextField * textField;
@property  BOOL isOpen;
@property  BOOL isEditing;

@end
@implementation MainScreenRow

@synthesize index = _index;
@synthesize animationManager = _animationManager;
@synthesize foregroundView = _foregroundView;

-(id) init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addBackgroundLayer];
        [self addActionButtons];
        [self addforgroundLayer];
        [self addLabelPlaceholder];
        [self addGestureRecognizers];
        self.animationManager = [[ListRowSlideAnimationManager alloc] init];
        self.layoutManager = [[SlidingTableRowLayoutManager alloc] init];
        self.isEditing = NO;
    }
    return self;
}

-(UITextField *) textField
{
    if (_textField == nil)
    {
        UITextField * textField = [[UITextField alloc] initWithFrame:self.collectionLabel.frame];
        [self addSubview:textField];
        textField.hidden = YES;
        textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        _textField = textField;
    }
    return _textField;
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
    self.foregroundView.frame = [self foregroundFrame];
    self.backgroundView.frame = [self backgroundFrame];
    self.collectionImage.frame = [self imageFrame];
    self.collectionLabel.frame = [self labelFrameWithForegroundRect:self.foregroundView.frame];
    NSArray * buttonFrames = [self getActionButtonFrames];
    self.shareButton.frame = [buttonFrames[0] CGRectValue];
    self.renameButton.frame = [buttonFrames[1] CGRectValue];
    self.deleteButton.frame = [buttonFrames[2] CGRectValue];
    if (self.isOpen)
    {
        CGRect openRect = [self.layoutManager frameForOpenedRow:self.bounds];
        [[ThemeFactory currentTheme] stylizeMainscreenRowForeground:self.foregroundView
                                                             isOpen:YES
                                                     withOpenBounds:openRect];
    }
    else
    {
        [[ThemeFactory currentTheme] stylizeMainscreenRowForeground:self.foregroundView
                                                             isOpen:NO
                                                     withOpenBounds:CGRectZero];
        
    }
    
    [self closeView];
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
    if (!self.isEditing && !self.isOpen && ![self.delegate isEditingRows])
    {
        [self closeView];
        UIColor * originalColor = self.foregroundView.backgroundColor;
        
        [UIView animateWithDuration:0.25 animations:^{
            self.foregroundView.backgroundColor = [[ThemeFactory currentTheme] colorForMainScreenRowSelected];
            //self.foregroundView.backgroundColor = [UIColor colorWithWhite:0.79 alpha:1];
        }completion:^(BOOL finished){
                        [UIView animateWithDuration:0.15 animations:^{
                self.foregroundView.backgroundColor = originalColor;
            }];
            [self.delegate selectedRow:self];
        }];
    }
    else
    {
        [self.delegate tappedRow:self];
    }
}

-(void) openView
{
    if (!self.isOpen)
    {
        self.isOpen = YES;
        CGRect openSize = [self.layoutManager frameForOpenedRow:self.foregroundView.frame];
        CGRect labelFrame = [self labelFrameWithForegroundRect:openSize];
        [self.animationManager slideOpenMainScreenRow:self.foregroundView
                                          withButtons:@[self.shareButton, self.renameButton, self.deleteButton] andLabel:self.collectionLabel
                                     toForegroundRect:openSize
                                         andLabelRect:labelFrame];
        
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
        
        CGRect foregroundRect = self.foregroundView.superview.bounds;
        CGRect labelFrame = [self labelFrameWithForegroundRect:foregroundRect];
        [self.animationManager slideCloseMainScreenRow:self.foregroundView
                                           withButtons:@[self.shareButton, self.deleteButton, self.renameButton] andLabel:self.collectionLabel
                                      toForegroundRect:foregroundRect
                                          andLabelRect:labelFrame withCompletion:^{
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
    [self addSubview:foregroundView];
    self.foregroundView = foregroundView;
    [self addImagePlaceHolder];
}

-(CGRect) foregroundFrame
{
    if (self.isOpen)
    {
        return [self.layoutManager frameForOpenedRow:self.bounds];
    }
    else
    {
        return self.bounds;
    }
}

-(void) addBackgroundLayer
{
    CGRect backgroundFrame = [self backgroundFrame];
    UIView * backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    backgroundView.backgroundColor = [UIColor whiteColor];
    self.backgroundView = backgroundView;
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
    CGRect addButtonFrame = [self.layoutManager frameForButtonInBounds:self.bounds WithBackgroundView:self.backgroundView];
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
    CGRect labelFrame = [self labelFrameWithForegroundRect:self.foregroundView.frame];
    UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:label];
    self.collectionLabel = label;
}

-(CGRect) labelFrameWithForegroundRect:(CGRect) newFrame;
{
    CGSize labelSize = CGSizeMake(newFrame.size.width - 2 * LABEL_INSET_HOR - self.collectionImage.frame.size.width,
                                  newFrame.size.height - 2 * LABEL_INSET_VER);
    CGPoint labelOrigin = CGPointMake(newFrame.origin.x + LABEL_INSET_HOR + self.collectionImage.frame.size.width,
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

-(void) enableEditing :(BOOL) makeFirstResponder
{
    [self closeView];
    self.collectionLabel.hidden = YES;
    self.textField.frame = self.collectionLabel.frame;
    self.textField.hidden = NO;
    self.textField.text = self.collectionLabel.text;
    if (makeFirstResponder)
    {
        [self.textField becomeFirstResponder];
    }
    self.isEditing = YES;
}

-(void) disableEditing:(BOOL) resignFirstResponser
{
    self.collectionLabel.hidden = NO;
    self.textField.hidden = YES;
    self.collectionLabel.text = self.textField.text;
    if (resignFirstResponser)
    {
        [self.textField resignFirstResponder];
    }
    self.isEditing = NO;
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

#pragma mark - Keyboard Delegate
-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [self disableEditing:YES];
}

@end
