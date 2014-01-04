//
//  StackViewController.m
//  IdeaStock
//
//  Created by Ali Fathalian on 5/17/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "StackViewController.h"
#import "NoteView.h"
#import "CollectionNote.h"
#import "MultimediaHelper.h"

@interface StackViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *stackView;
@property (weak,nonatomic) UIView * lastOverlappedView;
@property (strong, nonatomic) IBOutlet UIImageView *bgImage;

@property (nonatomic) BOOL isInEditMode; 
@property (weak, nonatomic) NoteView * highLightedNote;
@property (nonatomic) CGRect lastFrame;
@property (nonatomic) BOOL isLocked;
@property (nonatomic) int currentPage;
@property (nonatomic) int unstackCounter;
@property (nonatomic, assign) CGPoint lastPanPosition;
@property (nonatomic, strong) NSTimer * overlapTimer;
@property (atomic, assign) BOOL overlapAnimationInProgress;

@property (weak,nonatomic) NSMutableArray * notes;
@end

@implementation StackViewController

#pragma mark - synthesizer
@synthesize notes = _notes;
@synthesize activeView = _activeView;

#define MINIMUM_OBJECT_PRESS_DURATION 0.1
-(void) setOpenStack:(StackView *)openStack
{
    _openStack = openStack;
    [openStack stackWillOpen];
    for(NoteView * view in _openStack.views){
        for (UIGestureRecognizer * gr in [view gestureRecognizers]){
            [view removeGestureRecognizer:gr];
            [view resetSize];
        }
        UILongPressGestureRecognizer * pgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(notePressed:)];
        pgr.minimumPressDuration = MINIMUM_OBJECT_PRESS_DURATION;
        [view addGestureRecognizer:pgr];
    }
    
    self.notes = openStack.views;
}

#pragma mark - initializer
-(id) initWithNibName:(NSString *) nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Timer
-(void) fireTimer:(NSTimer *) timer{
    self.isLocked = false;
}

-(void) fireOverlapTimer: (NSTimer *) timer{
    self.lastOverlappedView = nil;
}

#pragma mark - gesture events
#define OVERLAP_PERIOD 0.5
-(void) notePressed: (UILongPressGestureRecognizer *) sender{
    
    if (sender.state == UIGestureRecognizerStateBegan){
        
        [self pressGestureStarted:sender];
    }
    else if (sender.state == UIGestureRecognizerStateChanged){
        
        [self pressGestureChanged:sender];
    }
    else if (sender.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.20
                         animations:^{
                             ;
//                             sender.view.center =
//                             CGPointMake(self.lastFrame.origin.x + self.lastFrame.size.width / 2 ,
//                                         self.lastFrame.origin.y + self.lastFrame.size.height/2);
                         }];
    }
}

-(void) pressGestureStarted:(UILongPressGestureRecognizer *) sender
{
    
    NoteView * noteView = ((NoteView *) sender.view);
    
    if (!noteView.selectedInStack)
    {
        noteView.selectedInStack = YES;
        //if there is another note selected, deselect it
        if (self.highLightedNote)
        {
            self.highLightedNote.selectedInStack = NO;
        }
        
        self.lastFrame = sender.view.frame;
        UIPanGestureRecognizer * pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(notePanned:)];
        [sender.view addGestureRecognizer:pgr];

        self.highLightedNote = noteView;
        self.isInEditMode = YES;
        self.lastPanPosition = [sender locationInView:self.stackView];
    }
    else
    {
        noteView.selectedInStack = NO;
        self.lastPanPosition = CGPointZero;
        //remove highlighting on the note and remove the ability for panning it
        self.highLightedNote = nil;
        self.isInEditMode = NO;
        for (UIGestureRecognizer * gr in [sender.view gestureRecognizers]){
            if ([gr isKindOfClass:[UIPanGestureRecognizer class]]){
                [sender.view removeGestureRecognizer:gr];
            }
        }
    }
}

-(void) pressGestureChanged:(UILongPressGestureRecognizer *) sender
{
    [self changePositionForHighlighted:sender];
    [self checkForOverlapsForHighlighted:sender];
}

-(void) checkForOverlapsForHighlighted:(UIGestureRecognizer *)sender
{
    //when we check for the overlapping view we make sure that we skip the
    //last overlapping view because if we it wiggles. Also we want to make sure that
    //we give enough time to the user to make sure he has the right intention to
    //replace the current overla[[ing view so after a period of overlap_period we
    //reset the overlapping view to nil to allow it to be caught in
    //the  checkForOverlapWithView method
    UIView * overlappingView = [self checkForOverlapWithView:sender.view];
    if (overlappingView){
        self.lastOverlappedView = overlappingView;
        if (self.overlapTimer)
        {
            [self.overlapTimer invalidate];
            self.overlapTimer = nil;
        }
        self.overlapTimer = [NSTimer scheduledTimerWithTimeInterval:OVERLAP_PERIOD
                                                             target:self
                                                           selector:@selector(fireOverlapTimer:) userInfo:nil
                                                            repeats:NO];
        //swap the frames of overlapping frame and the current frame
        CGRect tempFrame = overlappingView.frame;
        if (!self.overlapAnimationInProgress)
        {
            self.overlapAnimationInProgress = YES;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 overlappingView.frame = self.lastFrame;
                             }completion:^(BOOL finished){
                                 
                                 self.overlapAnimationInProgress = NO;
                                 self.lastFrame = tempFrame;
                             }];
        }
    }
}

-(void) changePositionForHighlighted:(UIGestureRecognizer *) sender
{
    //just adjust the position and scroll to the next page if necessary
    CGPoint newPosition = [sender locationInView:self.stackView];
    CGPoint translation = CGPointMake(newPosition.x - self.lastPanPosition.x,
                                      newPosition.y - self.lastPanPosition.y);
    
    self.lastPanPosition = newPosition;
    CGRect newRect = CGRectMake(sender.view.frame.origin.x + translation.x,
                                sender.view.frame.origin.y + translation.y,
                                sender.view.bounds.size.width,
                                sender.view.bounds.size.height);
    if ([self checkScrollToNextPage: newRect forView: sender.view]){
        
        if ( newRect.origin.x > sender.view.frame.origin.x)
        {
//            NSLog(@"Going to the Next Page");
////            newRect = CGRectMake(newRect.origin.x + self.stackView.frame.size.width, newRect.origin.y, newRect.size.width, newRect.size.height)  ;
//        }
//        else {
//            newRect = CGRectMake(newRect.origin.x - self.stackView.frame.size.width, newRect.origin.y, newRect.size.width, newRect.size.height)  ;
        }
    }
    sender.view.center = CGPointMake(sender.view.center.x + translation.x, sender.view.center.y + translation.y);
}

-(void) notePanned: (UIPanGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateEnded ||
        sender.state ==UIGestureRecognizerStateChanged)
    {
        [self changePositionForHighlighted:sender];
        [self checkForOverlapsForHighlighted:sender];
    }
    if (sender.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.25
                         animations:^{
            sender.view.frame = self.lastFrame;
                         }];
    }
}


#define ROW_COUNT 3
#define COL_COUNT 2
#define COL_SEPERATOR 0
#define ROW_SEPERATOR 0
#define SIDE_OFFSET 5
#define TOP_OFFSET 5

#pragma mark - layout
-(void) addPageToStackViewWithCurrentPageCount:(int) page
{
    CGSize size = CGSizeMake(self.stackView.frame.size.width * (page+1), self.stackView.frame.size.height);
    [self.stackView setContentSize:size];
}
-(void) layoutNotes: (BOOL) animated{
    
    int page = 0;
    int col = 0;
    int row = 0;
    float pageWidth = self.stackView.frame.size.width;
    float pageHeight = self.stackView.frame.size.height;
    float noteWidth = (pageWidth - ((2 * SIDE_OFFSET) + ((COL_COUNT - 1) * COL_SEPERATOR))) / COL_COUNT;
    float noteHeight = (pageHeight -((2 * TOP_OFFSET) + ((ROW_COUNT - 1) * COL_SEPERATOR))) / ROW_COUNT;
    float colSeperator = COL_SEPERATOR;
    float rowSeperator = ROW_SEPERATOR;
    
    BOOL needsNewPage = NO;
    //for every note we calculate its starting position and also the column and
    //the row of the next note. If the column and row of the note required a
    //new page we extend the stack view to that
    for (NoteView * view in self.notes)
    {
        if ([view.text isEqualToString:PLACEHOLDER_TEXT])
        {
            view.text = [view.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        if (needsNewPage){
            needsNewPage = NO;
            [self addPageToStackViewWithCurrentPageCount:page];
        }
        
        //find the set the starting to position
        CGFloat startX = ((page + 1) * SIDE_OFFSET) + (page * pageWidth) + (col * noteWidth) + (col * colSeperator);
        CGFloat startY = (TOP_OFFSET) + (row * noteHeight) + (row  * rowSeperator);
        CGRect viewFrame = CGRectMake(startX, startY, noteWidth, noteHeight);
        
        [((NoteView *) view) resizeToRect:viewFrame Animate:YES];
        [self.stackView addSubview:view];
        
        col++;
        if ( col >= COL_COUNT) {
            col = 0;
            row++;
            if ( row >= ROW_COUNT){
                row = 0 ;
                page++;
                needsNewPage = YES;
            }
        }
    }
    
}

- (UIView *) checkForOverlapWithView: (UIView *) senderView{
    for (UIView * view in self.notes){
        if (view != senderView && view != self.lastOverlappedView){
            CGRect halfViewFrame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width/2, view.frame.size.height/2);
            if (CGRectIntersectsRect(halfViewFrame,senderView.frame)){
                return view;
            }
        }
    }
    return nil;
}

-(BOOL) findFirstResponder:(UIView *) view
{
    if(view.isFirstResponder)
    {
        NSLog(@" FOUND %@", view);
        return YES;
    }
    if (view.subviews.count == 0)
    {
        return NO;
    }
    
    for(UIView * subView in view.subviews)
    {
        [self findFirstResponder:subView];
    }
    return NO;
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}
-(void) resetEditingMode
{
    //tap is used for cancelation of the typing or pressing
    if (self.isInEditMode){
        self.isInEditMode = NO;
        self.highLightedNote.selectedInStack = NO;
        for (UIGestureRecognizer * gr in [self.highLightedNote gestureRecognizers]){
            if ([gr isKindOfClass:[UIPanGestureRecognizer class]]){
                [self.highLightedNote removeGestureRecognizer:gr];
            }
            
        }
        [UIView animateWithDuration:0.25 animations:^{ self.highLightedNote.frame = self.lastFrame;}];
        self.highLightedNote = nil;
    }
    
    for(UIView * view in self.notes){
        if ([view conformsToProtocol:@protocol(BulletinBoardObject)]){
            id<BulletinBoardObject> obj = (id<BulletinBoardObject>) view;
            [obj resignSubViewsAsFirstResponder];
        }
    }
    
}

-(void) refresh
{
    for(NoteView * view in self.notes){
        for (UIGestureRecognizer * gr in [view gestureRecognizers]){
            [view removeGestureRecognizer:gr];
            [view resetSize];
        }
        UILongPressGestureRecognizer * pgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(notePressed:)];
        pgr.minimumPressDuration = MINIMUM_OBJECT_PRESS_DURATION;
        [view addGestureRecognizer:pgr];
        view.delegate = self;
    }
    
    [self resetEditingMode];
    [self layoutNotes:YES];
}
#define FLIP_PERIOD 1.5
-(BOOL) checkScrollToNextPage: (CGRect) rect forView: (UIView *) view{
    
    //get the total pages in the stacking
    int totalPages = self.stackView.contentSize.width / self.stackView.frame.size.width;
    totalPages-- ;
    //figure out the direction of movement
    BOOL movingRight = rect.origin.x > view.frame.origin.x ? YES : NO;
    
    //figure out the corners
    int leftCornerPage = rect.origin.x/ self.stackView.frame.size.width;
    int rightCornerPage = (rect.origin.x + rect.size.width)/self.stackView.frame.size.width;
    int middleCornerPage = (rect.origin.x + rect.size.width/2)/self.stackView.frame.size.width;
    if ( leftCornerPage == middleCornerPage && middleCornerPage == rightCornerPage ){
        self.currentPage = leftCornerPage;
    }
    
    if ( movingRight && 
        middleCornerPage > leftCornerPage &&
        middleCornerPage > self.currentPage &&
        middleCornerPage <= totalPages && 
        !self.isLocked){ 
        self.isLocked = true;
        [NSTimer scheduledTimerWithTimeInterval: FLIP_PERIOD 
                                         target:self 
                                       selector:@selector(fireTimer:) 
                                       userInfo:nil 
                                        repeats:NO];
        
        CGPoint offset = CGPointMake(self.stackView.frame.size.width + self.stackView.contentOffset.x, self.stackView.contentOffset.y);
        [self.stackView setContentOffset:offset animated:YES];
        return YES;
    }
    
    else if ( !movingRight && 
             middleCornerPage  < rightCornerPage &&
             middleCornerPage < self.currentPage &&
             middleCornerPage >= 0 &&
             !self.isLocked){
        
        self.isLocked = true;
        [NSTimer scheduledTimerWithTimeInterval: FLIP_PERIOD 
                                         target:self 
                                       selector:@selector(fireTimer:) 
                                       userInfo:nil 
                                        repeats:NO];
        CGPoint offset = CGPointMake(self.stackView.contentOffset.x- self.stackView.frame.size.width, self.stackView.contentOffset.y);
        [self.stackView setContentOffset:offset animated:YES];
        return YES;
        
    }
    return NO;
}

#pragma mark - UI Events

-(void) viewWillAppear:(BOOL)animated
{
    self.view.backgroundColor = [UIColor clearColor];
    UIColor * bgColor = [UIColor colorWithWhite:0.36 alpha:0.85];
    self.view.superview.backgroundColor = bgColor;
    self.view.superview.layer.cornerRadius = 15;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.stackView setContentSize:self.stackView.bounds.size];
    for (NoteView * view in self.notes){
        view.delegate = self;
        view._textView.editable = YES;
    }
    
    [self.stackView setBackgroundColor:[UIColor clearColor]];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self layoutNotes:NO];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
    
    [recognizer setNumberOfTapsRequired:1];
    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:recognizer];
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Then we convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            // Remove the recognizer first so it's view.window is valid.
            [self.view.window removeGestureRecognizer:sender];
            [self exitStack];
        }
        else
        {
            [self resetEditingMode];
        }
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    if (self.overlapTimer)
    {
        [self.overlapTimer invalidate];
        self.overlapTimer = nil;
    }
    NSString * replacedPlaceholder = [PLACEHOLDER_TEXT stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    for(NoteView * view in self.notes)
    {
        if ([view.text isEqualToString:replacedPlaceholder])
        {
            view.text = PLACEHOLDER_TEXT;
        }
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    for(NoteView * view in self.notes)
    {
        for (UIGestureRecognizer * gr in view.gestureRecognizers){
            [view removeGestureRecognizer:gr];
        }
    }
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    [self setStackView:nil];
}

-(void) exitStack
{
    if ( self.highLightedNote) self.highLightedNote.selectedInStack = NO;
    [self.delegate returnedstackViewController:self];
    [self.openStack stackWillClose];;
}

-(void)deletePressed:(id)sender
{
    
    
    [self.delegate stackViewDeletedNote:self.highLightedNote];
    [UIView animateWithDuration:0.5 animations:^{
        self.highLightedNote.transform = CGAffineTransformScale(self.highLightedNote.transform, 0.05, 0.05);
    }completion:^ (BOOL didFinish){
        
        [self.openStack removeNoteView:self.highLightedNote];
        [self.notes removeObject:self.highLightedNote];
        [self.highLightedNote removeFromSuperview];
        self.editing = NO;
        self.highLightedNote = nil;
        [self layoutNotes: YES];
        if ([self.notes count] == 0)
        {
            [self.delegate stack:self.openStack IsEmptyForViewController:self];
        }
    }];
    
}

-(IBAction)unstackPressed:(id)sender {
    
    [self.notes removeObject:self.highLightedNote];
    self.highLightedNote.selectedInStack = NO;
    [self.highLightedNote removeFromSuperview];
    self.unstackCounter++;
    [self.delegate unstackItem:self.highLightedNote
                      fromView:self.openStack 
                 withPastCount:self.unstackCounter];
    self.editing = NO;
    self.highLightedNote = nil;
    [self layoutNotes: YES];
    [UIView animateWithDuration:0.5 animations:^{self.highLightedNote.alpha = 0;} completion:^(BOOL finished){
    }];
    
    if ([self.notes count] == 0)
    {
        [self.delegate stack:self.openStack IsEmptyForViewController:self];
    }
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - textbox delegate
-(void) note:(id)note changedTextTo:(NSString *)text{
    if (!self.highLightedNote){
        [self.openStack setText: text];
    }
    [self.delegate note:note changedTextTo:text];
}

@end
