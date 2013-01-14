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

@interface StackViewController ()

/*========================================================================*/


/*-----------------------------------------------------------
                        UI Properties
 -----------------------------------------------------------*/

@property (weak, nonatomic) IBOutlet UIScrollView *stackView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong,nonatomic) UIBarButtonItem * deleteButton;
@property (strong,nonatomic) UIBarButtonItem * removeButton;
@property (weak,nonatomic) UIView * lastOverlappedView;

/*-----------------------------------------------------------
                        Modal Properties
 -----------------------------------------------------------*/

@property (nonatomic) BOOL isInEditMode; 
@property (weak, nonatomic) NoteView * highLightedNote;
@property (nonatomic) CGRect lastFrame;
@property (nonatomic) BOOL isLocked;
@property (nonatomic) int currentPage;
@property (nonatomic) int unstackCounter;


@end

/*========================================================================*/


@implementation StackViewController

/*-----------------------------------------------------------
                      Synthesizers
 -----------------------------------------------------------*/

@synthesize stackView = _stackView;
@synthesize isLocked = _isLocked;
@synthesize highLightedNote = _highLightedNote;
@synthesize isInEditMode = _isInEditMode;
@synthesize lastFrame = _lastFrame;
@synthesize currentPage = _currentPage;
@synthesize lastOverlappedView = _lastOverlappedView;
@synthesize toolbar = _toolbar;
@synthesize deleteButton = _deleteButton;
@synthesize removeButton = _removeButton;
@synthesize openStack = _openStack;
@synthesize unstackCounter = _unstackCounter;
@synthesize notes = _notes;
@synthesize delegate = _delegate;

-(void) setNotes:(NSMutableArray *)notes{
    _notes = notes;
    
    //remove the gesture recognizor from all the notes
    for(NoteView * view in _notes){
        for (UIGestureRecognizer * gr in [view gestureRecognizers]){
            [view removeGestureRecognizer:gr];
            [view resetSize];
            
        }
        
        UILongPressGestureRecognizer * pgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(notePressed:)];
        [view addGestureRecognizer:pgr];

    }
}

/*========================================================================*/

/*-----------------------------------------------------------
                        Initializers
 -----------------------------------------------------------*/

-(id) initWithNibName:(NSString *) nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*-----------------------------------------------------------
                        Timer Methods
 -----------------------------------------------------------*/

-(void) fireTimer:(NSTimer *) timer{
    self.isLocked = false;
}

-(void) fireOverlapTimer: (NSTimer *) timer{
    self.lastOverlappedView = nil;
}

/*-----------------------------------------------------------
                        Gesture Events
 -----------------------------------------------------------*/

#define OVERLAP_PERIOD 2
-(void) notePanned: (UIPanGestureRecognizer *) sender{
    
    if (sender.state == UIGestureRecognizerStateEnded || sender.state ==UIGestureRecognizerStateChanged){
        
        CGPoint newStart = [sender locationInView:self.stackView];
        CGRect newRect = CGRectMake(newStart.x, newStart.y, sender.view.bounds.size.width, sender.view.bounds.size.height);
        
        if ([self checkScrollToNextPage: newRect forView: sender.view]){
            if ( newRect.origin.x > sender.view.frame.origin.x){
                newRect = CGRectMake(newRect.origin.x + self.stackView.frame.size.width, newRect.origin.y, newRect.size.width, newRect.size.height)  ;
            }
            else {
                newRect = CGRectMake(newRect.origin.x - self.stackView.frame.size.width, newRect.origin.y, newRect.size.width, newRect.size.height)  ;
            }
        }
        
        [sender.view setFrame:newRect];
        UIView * overlappingView = [self checkForOverlapWithView:sender.view];
        if (overlappingView){
            self.lastOverlappedView = overlappingView;
            [NSTimer scheduledTimerWithTimeInterval:OVERLAP_PERIOD target:self selector:@selector(fireOverlapTimer:) userInfo:nil repeats:NO];
            CGRect tempFrame = overlappingView.frame;
            [UIView animateWithDuration:0.25 animations:^{ overlappingView.frame = self.lastFrame;}];
            self.lastFrame = tempFrame;
        }
        
    }
    if (sender.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.25 animations:^{sender.view.frame = self.lastFrame;}];
    }
}

-(void) notePressed: (UILongPressGestureRecognizer *) sender{
    if (sender.state == UIGestureRecognizerStateBegan){
        
        ((NoteView *) sender.view).highlighted = !((NoteView *) sender.view).highlighted;
        if ( ((NoteView *) sender.view).highlighted){
            if (self.highLightedNote) {
                [self removeToolbarItems];
                self.highLightedNote.highlighted = NO;
                
            }
            self.lastFrame = sender.view.frame;
            UIPanGestureRecognizer * pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(notePanned:)];
            [sender.view addGestureRecognizer:pgr];

            self.highLightedNote = (NoteView *) sender.view;
            self.isInEditMode = YES;
            [self addToolbarItems];
        }
        else{
            self.highLightedNote = nil;
            self.isInEditMode = NO;
            [self removeToolbarItems];
            for (UIGestureRecognizer * gr in [sender.view gestureRecognizers]){
                if ([gr isKindOfClass:[UIPanGestureRecognizer class]]){
                    [sender.view removeGestureRecognizer:gr];
                }
            }
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged){
        CGPoint newStart = [sender locationInView:self.stackView];
        
        CGRect newRect = CGRectMake(newStart.x, newStart.y, sender.view.bounds.size.width, sender.view.bounds.size.height);
        
        if ([self checkScrollToNextPage: newRect forView: sender.view]){
            if ( newRect.origin.x > sender.view.frame.origin.x){
                newRect = CGRectMake(newRect.origin.x + self.stackView.frame.size.width, newRect.origin.y, newRect.size.width, newRect.size.height)  ;
            }
            else {
                newRect = CGRectMake(newRect.origin.x - self.stackView.frame.size.width, newRect.origin.y, newRect.size.width, newRect.size.height)  ;
            }
        }

        [sender.view setFrame:newRect];
        UIView * overlappingView = [self checkForOverlapWithView:sender.view];
        if (overlappingView){
            self.lastOverlappedView = overlappingView;
            [NSTimer scheduledTimerWithTimeInterval:OVERLAP_PERIOD target:self selector:@selector(fireOverlapTimer:) userInfo:nil repeats:NO];
            CGRect tempFrame = overlappingView.frame;
            [UIView animateWithDuration:0.25 animations:^{ overlappingView.frame = self.lastFrame;}];
            self.lastFrame = tempFrame;
        }
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.25 animations:^{sender.view.frame = self.lastFrame;}];
    }
    
}

-(void) screenTapped: (UITapGestureRecognizer *) sender{

    if (self.isInEditMode){
        self.isInEditMode = NO;
        self.highLightedNote.highlighted = NO;
        if ([self.toolbar.items count] > 2){
            [self removeToolbarItems];
        }
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
            [obj resignFirstResponder];
        }
    }
}

/*-----------------------------------------------------------
 UI Action Helper
 -----------------------------------------------------------*/

#define ROW_COUNT 2
#define COL_COUNT 2
-(void) addToolbarItems{
    NSMutableArray * currentItems = [self.toolbar.items mutableCopy];
    [currentItems addObject:self.removeButton];
    [currentItems addObject:self.deleteButton];
    self.toolbar.items = [currentItems copy];
}

-(void) removeToolbarItems{
    NSMutableArray * currentItems = [self.toolbar.items mutableCopy];
    [currentItems removeLastObject];
    [currentItems removeLastObject];
    self.toolbar.items = currentItems;
}

/*-----------------------------------------------------------
                            Layout methods
 -----------------------------------------------------------*/

-(void) layoutNotes: (BOOL) animated{
    
    int pageNotes = ROW_COUNT * COL_COUNT;
    int totalNotes = [self.notes count];
    int totalPages = totalNotes/pageNotes;
    if ( totalNotes % pageNotes > 0 ) totalPages++;
    
    
    int page = 0;
    int col = 0;
    int row = 0;
    
    
    float pageWidth = self.stackView.frame.size.width;
    float pageHeight = self.stackView.frame.size.height;
    float noteWidth = (pageWidth / COL_COUNT ) * 0.82;
    float noteHeight = (pageHeight / ROW_COUNT ) * 0.75;
    float colSeperator = noteWidth / 7;
    float rowSeperator = noteHeight / 5;
    
    BOOL needResizing = NO;
    for (UIView * view in self.notes){
        
        if (needResizing){
            needResizing = NO;
            CGSize size = CGSizeMake(self.stackView.frame.size.width * (page+1), self.stackView.frame.size.height);
            [self.stackView setContentSize:size];
        }
        CGFloat startX = (page * pageWidth) + (col * noteWidth) + ((col+1) * colSeperator);
        CGFloat startY = (row * noteHeight) + ((row + 1) * rowSeperator);
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
                needResizing = YES;
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

#define FLIP_PERIOD 1.5
-(BOOL) checkScrollToNextPage: (CGRect) rect forView: (UIView *) view{
    
    BOOL movingRight = rect.origin.x > view.frame.origin.x ? YES : NO;
    int totalPages = self.stackView.contentSize.width / self.stackView.frame.size.width;
    totalPages-- ;
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
      //  NSLog(@"content size after offset : %f", self.stackView.contentSize.width);
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
    //    NSLog(@"content size after offset : %f", self.stackView.contentSize.width);
        return YES;
        
    }
    return NO;
}

/*-----------------------------------------------------------
                            UI Events
 -----------------------------------------------------------*/
-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.stackView setContentSize:self.stackView.bounds.size];
    NSLog(@"Notes here: %d", [self.notes count]);
    for (NoteView * view in self.notes){
        view.delegate = self;
    }
    NSMutableArray * toolbar = [self.toolbar.items mutableCopy];
    self.deleteButton = [toolbar lastObject];
    [toolbar removeLastObject];
    self.removeButton = [toolbar lastObject];
    [toolbar removeLastObject];
    
    self.toolbar.items = [toolbar copy];
    [self layoutNotes:NO];
    
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    [self.stackView addGestureRecognizer:tgr];
    [self.stackView setBackgroundColor:[UIColor clearColor]];
}

-(void)viewDidUnload
{
    [self setStackView:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(IBAction)backPressed:(id)sender{
    if ( self.highLightedNote) self.highLightedNote.highlighted = NO;
    [self.delegate returnedstackViewController:self];
}

-(IBAction)deletePressed:(id)sender {
    
    
    [UIView animateWithDuration:0.5 animations:^{
        self.highLightedNote.transform = CGAffineTransformScale(self.highLightedNote.transform, 0.05, 0.05);
    }completion:^ (BOOL didFinish){
        
        if (self.highLightedNote == self.openStack.mainView){
            [self.openStack setNextMainView];
        }
        [self.notes removeObject:self.highLightedNote];
        [self.highLightedNote removeFromSuperview];
        [self removeToolbarItems];
        self.editing = NO;
        self.highLightedNote = nil;
        [self layoutNotes: YES];

    }];
    
}

-(IBAction)unstackPressed:(id)sender {
    
    [self.notes removeObject:self.highLightedNote];
    self.highLightedNote.highlighted = NO;
    [self.highLightedNote removeFromSuperview];
    self.unstackCounter++;
    [self.delegate unstackItem:self.highLightedNote
                      fromView:self.openStack 
                 withPastCount:self.unstackCounter];
    [self removeToolbarItems];
    self.editing = NO;
    self.highLightedNote = nil;
    [self layoutNotes: YES];
    [UIView animateWithDuration:0.5 animations:^{self.highLightedNote.alpha = 0;} completion:^(BOOL finished){
     
        
        
    }];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

/*-----------------------------------------------------------
                        Note Delegate Protocol
 -----------------------------------------------------------*/

-(void) note:(id)note changedTextTo:(NSString *)text{
    [self.openStack setText: text];
    [self.delegate note:note changedTextTo:text];
}

@end
