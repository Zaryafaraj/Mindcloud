//
//  NoteRow.m
//  Lists
//
//  Created by Ali Fathalian on 4/30/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "NoteRow.h"
#import "ThemeFactory.h"
#import "NoteTableRowLayoutManager.h"
#import "CollectionRowPaperAnimationManager.h"
#import "AwesomeMenu.h"

#define LABEL_INSET_HOR 10
#define LABEL_INSET_VER 10
@interface NoteRow()

@property (strong, nonatomic) UITextField * textField;
@property (strong, nonatomic) UIView * backgroundView;
@property (strong, nonatomic) UIButton * doneButton;
@property  BOOL isOpen;
@property  BOOL isDone;
@property  BOOL isEditing;
@end

@implementation NoteRow

@synthesize index = _index;
@synthesize animationManager = _animationManager;
@synthesize foregroundView = _foregroundView;
@synthesize contextualMenu = _contextualMenu;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.layoutManager = [[NoteTableRowLayoutManager alloc] init];
        self.animationManager = [[CollectionRowPaperAnimationManager alloc] init];
        self.backgroundColor = [UIColor clearColor];
        [self addBackgroundLayer];
        [self addActionButtons];
        [self addForegroundLayer];
        [self addTextField];
        [self addGestureRecognizers];
        self.isEditing = NO;
    }
    return self;
}

-(void) setContextualMenu:(AwesomeMenu *)contextualMenu
{
    if (_contextualMenu)
    {
        [_contextualMenu removeFromSuperview];
    }
    _contextualMenu = contextualMenu;
    _contextualMenu.delegate = self;
}

-(void) setAlpha:(CGFloat)alpha
{
    //don't invoke super
    //because there are views with alpha zero on top of these
    //[super setAlpha:alpha];
    self.foregroundView.alpha = alpha;
    self.backgroundView.alpha = alpha;
    self.textField.alpha = alpha;
    self.doneButton.alpha = alpha;
}

-(void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.foregroundView.frame = [self foregroundFrame];
    self.backgroundView.frame = [self backgroundFrame];
    self.textField.frame = [self labelFrameWithForegroundRect:self.foregroundView.frame];
    CGRect buttonFrame = [self getActionButtonFrame];
    self.doneButton.frame = buttonFrame;
    if (self.isOpen)
    {
        CGRect openRect = [self.layoutManager frameForOpenedRow:self.bounds];
        [[ThemeFactory currentTheme] stylizeCollectionScreenRowForeground:self.foregroundView
                                                             isOpen:YES
                                                     withOpenBounds:openRect];
    }
    else
    {
        [[ThemeFactory currentTheme] stylizeCollectionScreenRowForeground:self.foregroundView
                                                             isOpen:NO
                                                     withOpenBounds:CGRectZero];
        
    }
    

    [self closeView];
}

-(void) setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.foregroundView.backgroundColor = backgroundColor;
}

-(UITextField *) textField
{
    if (_textField == nil)
    {
        UITextField * textField = [[UITextField alloc] initWithFrame:self.foregroundView. frame];
        [self addSubview:textField];
        textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.delegate = self;
        textField.backgroundColor = [UIColor clearColor];
        textField.adjustsFontSizeToFitWidth = YES;
        _textField = textField;
    }
    return _textField;
}

-(void) setText:(NSString *)text
{
    self.textField.text = text;
}

-(NSString *) text
{
    return self.textField.text;
}

-(void) addBackgroundLayer
{
    CGRect backgroundFrame = [self backgroundFrame];
    UIView * backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView = backgroundView;
    [self addSubview:backgroundView];
}

-(CGRect) backgroundFrame
{
    return self.bounds;
}

-(void) addActionButtons
{
    CGRect frame = [self getActionButtonFrame];
    UIButton * doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchDown];
    UIImage * doneImage = [[ThemeFactory currentTheme] imageForCollectionRowDone];
    [doneButton setBackgroundImage:doneImage
                          forState:UIControlStateNormal];
    doneButton.frame = frame;
    self.doneButton = doneButton;
    [[ThemeFactory currentTheme] stylizeCollectionScreenRowButton:doneButton];
    [self addSubview:doneButton];
    [self hideButtons:NO];
}

-(CGRect) getActionButtonFrame
{
    return [self.layoutManager frameForButtonInBounds:self.bounds
                                   WithBackgroundView:self.backgroundView];
}

-(void) hideButtons:(BOOL) animated
{
    self.doneButton.hidden = YES;
}

-(void) showButtons:(BOOL) animated
{
    self.doneButton.hidden = NO;
}

-(void) deletePressed:(id) sender
{
    [self.delegate deletePressed:self];
}

-(void) donePressed:(id) sender
{
    [self closeView];
    if(self.isDone)
    {
        self.isDone = NO;
        UIImage * doneImage = [[ThemeFactory currentTheme] imageForCollectionRowDone];
        [self.doneButton setBackgroundImage:doneImage
                                   forState:UIControlStateNormal];
        [[ThemeFactory currentTheme] stylizeCollectionScreenRowButton:self.doneButton];

        [self.delegate undoneTaskPressed:self];
    }
    else
    {
        self.isDone = YES;
        UIImage * undoneImage = [[ThemeFactory currentTheme] imageForCollectionRowUnDone];
        [self.doneButton setBackgroundImage:undoneImage
                              forState:UIControlStateNormal];
        [[ThemeFactory currentTheme] stylizeCollectionScreenRowButton:self.doneButton];
        [self.delegate doneTaskPressed:self];
    }
}

-(void) addForegroundLayer
{
    CGRect foregroundFrame = [self foregroundFrame];
    UIView * foregroundView = [[UIView alloc] initWithFrame:foregroundFrame];
    foregroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:foregroundView];
    self.foregroundView = foregroundView;
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

-(void) addTextField
{
    CGRect textFrame = [self labelFrameWithForegroundRect:self.foregroundView.frame];
    self.textField.frame = textFrame;
    [self addSubview:self.textField];
}

-(CGRect) labelFrameWithForegroundRect:(CGRect) newFrame;
{
    CGSize labelSize = CGSizeMake(newFrame.size.width - 2 * LABEL_INSET_HOR,
                                  newFrame.size.height - 2 * LABEL_INSET_VER);
    CGPoint labelOrigin = CGPointMake(newFrame.origin.x + LABEL_INSET_HOR,
                                      LABEL_INSET_VER);
    CGRect labelFrame = CGRectMake(labelOrigin.x, labelOrigin.y,
                                   labelSize.width, labelSize.height);
    return labelFrame;
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
    
    [self.delegate tappedRow:self];
}

-(void) openView
{
    if (!self.isOpen)
    {
        self.isOpen = YES;
        CGRect openSize = [self.layoutManager frameForOpenedRow:self.foregroundView.frame];
        CGRect labelFrame = [self labelFrameWithForegroundRect:openSize];
        [self.animationManager slideOpenMainScreenRow:self.foregroundView
                                          withButtons:@[self.doneButton]
                                             andLabel:self.textField
                                     toForegroundRect:openSize
                                         andLabelRect:labelFrame];
        
        [[ThemeFactory currentTheme] stylizeCollectionScreenRowForeground:self.foregroundView
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
                                           withButtons:@[self.doneButton]
                                              andLabel:self.textField
                                      toForegroundRect:foregroundRect
                                          andLabelRect:labelFrame withCompletion:^{
                                              [[ThemeFactory currentTheme] stylizeCollectionScreenRowForeground:self.foregroundView
                                                                                                   isOpen:NO
                                                                                           withOpenBounds:CGRectZero];
                                          }];
        
    }
}



-(void) enableEditing:(BOOL)makeFirstResponder
{
    if (makeFirstResponder)
    {
        [self.textField becomeFirstResponder];
    }
    self.isEditing = YES;
}

-(void) disableEditing:(BOOL)resignFirstResponser
{
    if (resignFirstResponser)
    {
        [self.textField resignFirstResponder];
    }
    self.isEditing = NO;
}

-(UIView<ListRow> *) prototypeSelf
{
    NoteRow * prototype = [[NoteRow alloc] init];
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
    return self.textField.text;
}

-(void) removeFromSuperview
{
    [super removeFromSuperview];
    [self.contextualMenu removeFromSuperview];
}

#pragma mark - Keyboard Delegate
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self.delegate tappedRow:self];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [self disableEditing:YES];
}

#pragma mark - Awesome menu delegate

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    
}

- (void)AwesomeMenuDidFinishAnimationClose:(AwesomeMenu *)menu
{
    
}
- (void)AwesomeMenuDidFinishAnimationOpen:(AwesomeMenu *)menu
{
    
}

-(void) AwesomeMenuWillGetActivated:(AwesomeMenu *)menu
{
    UIView * superView = menu.superview;
    [superView bringSubviewToFront:menu];
}
@end
