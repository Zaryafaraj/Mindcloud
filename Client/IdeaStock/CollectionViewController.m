//
//  CollectionViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionViewController.h"

#import "NoteView.h"
#import "StackView.h"
#import "StackViewController.h"
#import "CollectionNote.h"
#import "XoomlAttributeHelper.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ImageView.h"
#import "CachedMindCloudDataSource.h"
#import "EventTypes.h"
#import "CollectionLayoutHelper.h"
#import "CollectionAnimationHelper.h"

@interface CollectionViewController ()

#pragma mark - UI Elements
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIBarButtonItem * deleteButton;
@property (strong, nonatomic) UIBarButtonItem * expandButton;
@property (weak, nonatomic) IBOutlet UIScrollView *collectionView;

@property int noteCount;
@property (strong, nonatomic) NSArray * intersectingViews;
@property (weak, nonatomic) UIView<BulletinBoardObject> * highlightedView;
@property (nonatomic) BOOL editMode;
@property int panCounter ;
@property BOOL isRefreshing;
@property (nonatomic) CollectionLayoutHelper * layoutHelper;

@end

#pragma mark - Definitions

#define NOTE_WIDTH 200
#define NOTE_HEIGHT 200
#define POSITION_X_TYPE @"positionX"
#define POSITION_Y_TYPE @"positionY"
#define POSITION_TYPE @"position"
#define STACKING_TYPE @"stacking"
//0 is the max
#define IMG_COMPRESSION_QUALITY 0.5
#define CHECK_TIME 0

@implementation CollectionViewController

#pragma mark - getter/setters
-(MindcloudCollection *) board{
    
    if (!_board){
        _board = [[MindcloudCollection alloc] initCollection:self.bulletinBoardName
                                              withDataSource:[CachedMindCloudDataSource getInstance:self.bulletinBoardName]];
    }
    return _board;
}

-(CollectionLayoutHelper *) layoutHelper
{
    if (!_layoutHelper)
    {
        _layoutHelper = [[CollectionLayoutHelper alloc] initWithNoteWidth:NOTE_WIDTH andHeight:NOTE_HEIGHT];
    }
    return _layoutHelper;
}

#pragma mark - Contextual Toolbar

-(void) removeContextualToolbarItems:(UIView *) contextView{
    
    NSMutableArray * newToolbarItems = [self.toolbar.items mutableCopy];
    [newToolbarItems removeLastObject];
    if( [contextView isKindOfClass:[StackView class]]){
        [newToolbarItems removeLastObject];
    }
    self.toolbar.items = newToolbarItems;
}

-(void) addContextualToolbarItems: (UIView *) contextView{
    NSMutableArray * newToolbarItems = [self.toolbar.items mutableCopy];
    if ( [contextView isKindOfClass:[StackView class]]){
        [newToolbarItems addObject:self.expandButton];
    }
    [newToolbarItems addObject:self.deleteButton];
    self.toolbar.items = newToolbarItems;
}

#pragma mark - Note Actions

-(NSString *) addNoteToModel: (NoteView *) note
{
    
    NSString * noteTextID = [XoomlAttributeHelper generateUUID];
    NSString * creationDate = [XoomlAttributeHelper generateCurrentTimeForXooml];
    NSString * noteID = [XoomlAttributeHelper generateUUID];
    
    NSString * noteName = [NSString stringWithFormat:@"Note%d",self.noteCount];
    self.noteCount++;
    NSString * positionX = [NSString stringWithFormat:@"%f", note.frame.origin.x];
    NSStream * positionY = [NSString stringWithFormat:@"%f", note.frame.origin.y];
    
    NSDictionary * noteProperties =@{@"name": noteName,
                                    @"ID": noteID,
                                    @"positionX": positionX,
                                    @"positionY": positionY,
                                    @"isVisible": @"true"};
    CollectionNote * noteItem = [[CollectionNote alloc] initEmptyNoteWithID:noteTextID
                                                                    andDate:creationDate];
    noteItem.noteText = note.text;
    
    [self.board addNoteContent:noteItem andProperties:noteProperties];
    note.ID = noteID;
    
    return noteID;
}

-(NSString *) addImageNoteToModel: (ImageView *) note
{
    
    NSString * noteTextID = [XoomlAttributeHelper generateUUID];
    NSString * creationDate = [XoomlAttributeHelper generateCurrentTimeForXooml];
    NSString * noteID = [XoomlAttributeHelper generateUUID];
    
    NSString * noteName = [NSString stringWithFormat:@"Note%d",self.noteCount];
    self.noteCount++;
    NSString * positionX = [NSString stringWithFormat:@"%f", note.frame.origin.x];
    NSStream * positionY = [NSString stringWithFormat:@"%f", note.frame.origin.y];
    
    NSDictionary * noteProperties =@{@"name": noteName,
                                    @"ID": noteID,
                                    @"positionX": positionX,
                                    @"positionY": positionY,
                                    @"isVisible": @"true"};
    
    CollectionNote * noteItem = [[CollectionNote alloc] initEmptyNoteWithID:noteTextID
                                                                    andDate:creationDate];
    noteItem.noteText = note.text;
    note.ID = noteID;
    NSData * imgData = UIImageJPEGRepresentation(note.image, IMG_COMPRESSION_QUALITY);
    
    [self.board addImageNoteContent:noteItem
                      andProperties:noteProperties
                           andImage: imgData];
    
    return noteID;
}

-(void) updateNoteLocation:(NoteView *) view
{
    NSString * noteID = view.ID;
    float positionFloat = view.frame.origin.x;
    NSString * positionX = [NSString stringWithFormat:@"%f",positionFloat];
    positionFloat = view.frame.origin.y;
    NSString * positionY = [NSString stringWithFormat:@"%f",positionFloat];
    
    NSArray * positionXArr = @[positionX];
    NSArray * positionYArr = @[positionY];
    NSDictionary * position = @{POSITION_X_TYPE: positionXArr,
                               POSITION_Y_TYPE: positionYArr};
    NSDictionary * newProperties = @{POSITION_TYPE: position};
    
    [self.board updateNoteAttributes:noteID
                      withAttributes:newProperties];
}

- (NSMutableArray *) getAllNormalNotesInViews: (NSArray *) views
{
    NSMutableArray * ans = [[NSMutableArray alloc] init];
    for (UIView * view in views){
        if ([view isKindOfClass: [NoteView class]]){
            [ans addObject:view];
        }
        else if ([view isKindOfClass:[StackView class]]){
            [view removeFromSuperview];
            [ans addObjectsFromArray:((StackView *) view).views];
        }
    }
    return ans;
}

#pragma mark - Notifications

-(void) loadSavedNotes: (NSNotification *) notificatoin{
    NSLog(@"Reloading collection");
    [self clearView];
    [self layoutNotes];
}

#pragma mark - Layout Helpers

-(void) clearView
{
    for(UIView * view in self.collectionView.subviews){
        [view removeFromSuperview];
    }
}

-(NoteView *) getNoteViewForNote: (NSString *) noteID
                            ForX:(float) positionX
                            andY:(float) positionY
{
    
    NSDictionary * allImgs = [self.board getAllNoteImages];
    CGRect noteFrame = CGRectMake(positionX, positionY, NOTE_WIDTH, NOTE_HEIGHT);
    NoteView * note ;
    if (allImgs[noteID]){
        UIImage * img = [[UIImage alloc] initWithData:allImgs[noteID]];
        note = [[ImageView alloc] initWithFrame:noteFrame 
                                                andImage:img];
    }
    else{
        note = [[NoteView alloc] initWithFrame:noteFrame];
    }
    return note;
}

/*
 If ID is nil the methods will create a unique UUID itself and will also write
 to the datamodel.The nil id means that this is a fresh stacking
 If ID is not nil it means that stacking is formed from the datamodel of an existing stacking
 */
-(void) stackNotes: (NSArray *) items
              into: (UIView *) mainView
            withID: (NSString *) ID{
    
    NSMutableArray * allNotes = [self getAllNormalNotesInViews:items];
    
    CGRect stackFrame = [self.layoutHelper getStackingFrameForStackingWithTopView:mainView];
    
    BOOL isNewStack = ID == nil ? YES : NO;
    NSString * stackingID = isNewStack ? [self mergeItems: items
                                 intoStackingWithMainView: mainView] :ID;
    
    StackView * stack = [[StackView alloc] initWithViews:allNotes
                                             andMainView:(NoteView *)mainView
                                               withFrame:stackFrame];
    stack.ID = stackingID;
    
    [self addGestureRecognizersToStack:stack];
    [CollectionAnimationHelper animateStackCreationForStackView:stack
                                                   WithMainView:mainView
                                                  andStackItems:items
                                               inCollectionView:self.collectionView
                                                          isNew:isNewStack
                                           withMoveNoteFunction:^(NoteView * note){
        [self updateNoteLocation:note];
    }];
}

-(NSString *) mergeItems: (NSArray *)items
intoStackingWithMainView: (UIView *) mainView
{
    NSString * stackingID = [XoomlAttributeHelper generateUUID];
    
    NSMutableArray * stackingNoteIDs = [NSMutableArray array];
    for(UIView * view in items)
    {
        if ([view isKindOfClass:[NoteView class]]){
            
            [stackingNoteIDs addObject:((NoteView *) view).ID];
        }
        else if ([view isKindOfClass:[StackView class]]){
            
            NSString * oldStackingID = ((StackView *)view).ID;
            [self.board removeBulletinBoardAttribute:oldStackingID
                                              ofType:STACKING_TYPE];
            for (UIView * note in ((StackView *)view).views){
                NSString *stackingNoteID = ((NoteView *)note).ID;
                [stackingNoteIDs addObject:stackingNoteID]; }
        }
    }
    
    NSString * topItemID;
    if ([mainView isKindOfClass:[NoteView class]]){
        topItemID = ((NoteView *) mainView).ID;
    }
    else if ([mainView isKindOfClass:[StackView class]]){
        topItemID = ((StackView *)mainView).mainView.ID;
    }
    
    if (topItemID == nil) return stackingID;
    //make sure that the top of the stack is at index 0
    [stackingNoteIDs removeObject:topItemID];
    [stackingNoteIDs insertObject:topItemID atIndex:0];
    
    for(NSString * noteID in stackingNoteIDs){
        [self.board addNoteWithID:noteID
         toBulletinBoardAttribute:stackingID
                 forAttributeType:STACKING_TYPE];
    }
    return stackingID;
}

#pragma mark - Gesture recoginizers
-(void) addGestureRecognizersToNote:(NoteView *)note
{
    UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectPanned:)];
    UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(objectPinched:)];
    UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(objectPressed:)];
    
    [note addGestureRecognizer:lpgr];
    [note addGestureRecognizer:gr];
    [note addGestureRecognizer:pgr];
}

-(void) addGestureRecognizersToStack:(StackView *) stack
{
    UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectPanned:)];
    UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(objectPinched:)];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stackTapped:)];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(objectPressed:)];
    [stack addGestureRecognizer:gr];
    [stack addGestureRecognizer:pgr];
    [stack addGestureRecognizer:tgr];
    [stack addGestureRecognizer:lpgr];
}

-(void) removeNotesFromStackView: (StackView *) stack
{
    
    NSArray * items = stack.views;
    [self removeNotesFromStackView: stack];
    //now find the size of the seperator from any note
    
    for (NoteView * view in items){
        //make your self responsible for actions happening to note not the stack view
        view.delegate = self;
        for (UIGestureRecognizer * gr in view.gestureRecognizers){
            [view removeGestureRecognizer:gr];
        }
        [self addGestureRecognizersToNote:view];
        
        [view resetSize];
        [view removeFromSuperview];
        [self.collectionView addSubview:view];
        
        //put it in the collection views frame
        CGRect viewTempFrame = CGRectMake(stack.frame.origin.x, stack.frame.origin.y, view.frame.size.width, view.frame.size.height);
        view.frame = viewTempFrame;
    }
}

-(void) layoutStackView: (StackView *) stack inRect: (CGRect) rect{
    
    NSArray * items = stack.views;
    [self removeNotesFromStackView:stack];
    [CollectionAnimationHelper animateStackViewRemoval:stack];
    [self.layoutHelper expandNotes:items inRect:rect withMoveNoteFunction:^(NoteView * noteView){
        [self updateNoteLocation:noteView];
    }];
}


#pragma mark - layout methods

-(void) layoutNotes{
    
    NSDictionary * allNotes = [self.board getAllNotes];
    for(NSString* noteID in [allNotes allKeys]){
        CollectionNote * noteObj = allNotes[noteID];
        NSDictionary * noteAttributes = [self.board getAllNoteAttributesForNote:noteID];
        NSDictionary * position = noteAttributes[@"position"];
        float positionX = [[position[@"positionX"] lastObject] floatValue];
        float positionY = [[position[@"positionY"] lastObject] floatValue];
        
        [self.layoutHelper adjustNotePositionsForX:&positionX
                                              andY:&positionY
                                            inView: self.collectionView];
        
        NoteView * note = [self getNoteViewForNote:noteID
                                              ForX:positionX
                                              andY:positionY];
        if (noteObj.noteText) note.text = noteObj.noteText;
        note.ID = noteID;
        note.delegate = self;
        
        [CollectionAnimationHelper animateNoteAddition:note
                                      toCollectionView:self.collectionView];
        [self addGestureRecognizersToNote:note];
    }
    
    [self layoutStackings];
}


-(void) layoutStackings{
    NSDictionary * stackings =[self.board getAllBulletinBoardAttributeNamesOfType:STACKING_TYPE];
    
    //Find out which notes belong to the stacking and put them there
    for(NSString * stackingID in stackings){
        NSMutableArray * views = [[NSMutableArray alloc] init];
        NSArray * noteRefIDs = stackings[stackingID];
        UIView * mainView = [self.layoutHelper gatherNoteViewFor:noteRefIDs fromCollectionView: self.collectionView into:views];
        [self stackNotes:views into:mainView withID:stackingID];
    }
}


#pragma mark - Gesture Events

-(void) screenTapped: (UITapGestureRecognizer *) sender{
    if (self.editMode){
        self.editMode = NO;
        self.highlightedView.highlighted = NO;
        [self removeContextualToolbarItems:self.highlightedView];
        if ([self.highlightedView isKindOfClass:[NoteView class]]){
            [self updateNoteLocation:(NoteView *) self.highlightedView];
        }
        else if ([self.highlightedView isKindOfClass:[StackView class]]){
            StackView * stack = (StackView *)self.highlightedView;
            for(NoteView * stackNoteView in stack.views){
                stackNoteView.frame = stack.frame;
                [self updateNoteLocation:stackNoteView];
            }
        }
        self.highlightedView = nil;
        
    }
    
    
    [self resignFirstResponders];
}

-(void) mainScreenDoubleTapped:(UITapGestureRecognizer *) sender{
    
    if (self.editMode) return;
    
    CGPoint location = [sender locationOfTouch:0 inView:self.collectionView];
    CGRect frame = CGRectMake(location.x, location.y, NOTE_WIDTH, NOTE_HEIGHT);
    
    
    BOOL frameChanged = NO;
    CGFloat newOriginX = frame.origin.x;
    CGFloat newOriginY = frame.origin.y;
    
    
    if (frame.origin.x < self.collectionView.frame.origin.x){
        frameChanged = YES;
        newOriginX = self.collectionView.frame.origin.x;
    }
    if (frame.origin.y < self.collectionView.frame.origin.y){
        frameChanged = YES;
        newOriginY = self.collectionView.frame.origin.y;
    }
    if (frame.origin.x + frame.size.width > 
        self.collectionView.frame.origin.x + self.collectionView.frame.size.width){
        frameChanged = YES;
        newOriginX = self.collectionView.frame.origin.x + self.collectionView.frame.size.width - frame.size.width;
    }
    if (frame.origin.y + frame.size.height > 
        self.collectionView.frame.origin.y + self.collectionView.frame.size.height){
        frameChanged = YES;
        newOriginY = self.collectionView.frame.origin.y + self.collectionView.frame.size.height - frame.size.height - 50;
    }
    
    if (sender.view.frame.origin.x + sender.view.frame.size.width > 
        self.collectionView.frame.origin.x + self.collectionView.frame.size.width){
        frameChanged = YES;
        newOriginX = self.collectionView.frame.origin.x + self.collectionView.frame.size.width - sender.view.frame.size.width;
    }
    if (sender.view.frame.origin.y + sender.view.frame.size.height > 
        self.collectionView.frame.origin.y + self.collectionView.frame.size.height){
        frameChanged = YES;
        newOriginY = self.collectionView.frame.origin.y + self.collectionView.frame.size.height - sender.view.frame.size.height - 50;
    }
    if (frameChanged){
            frame = CGRectMake(newOriginX, newOriginY,frame.size.width, frame.size.height);

    }
    
    NoteView * note = [[NoteView alloc] initWithFrame:frame];
    note.transform = CGAffineTransformScale(note.transform, 10, 10);
    note.alpha = 0;
    note.delegate = self;
    
    [UIView animateWithDuration:0.25 animations:^{
        note.transform = CGAffineTransformScale(note.transform, 0.1, 0.1);
        note.alpha = 1;
    }];
    
    [self.collectionView addSubview:note];
    UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectPanned:)];
    UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(objectPinched:)];
    UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(objectPressed:)];
    
    [note addGestureRecognizer:lpgr];
    [note addGestureRecognizer:gr];
    [note addGestureRecognizer:pgr];
    
    [self addNoteToModel:note];
}

-(void) objectPressed: (UILongPressGestureRecognizer *) sender{
    
    
    if ( sender.state == UIGestureRecognizerStateBegan){
        
        if (self.highlightedView && self.highlightedView != sender.view){
            self.highlightedView.highlighted = NO;
            [self removeContextualToolbarItems:self.highlightedView];
            self.highlightedView = (UIView <BulletinBoardObject> *) sender.view;
            [self addContextualToolbarItems:self.highlightedView];
            self.highlightedView.highlighted = YES;
            
        }
        else if (self.editMode){
            self.editMode = NO;
            self.highlightedView = nil;
            [self removeContextualToolbarItems:sender.view];
            
            if ([sender.view conformsToProtocol:@protocol(BulletinBoardObject)]){
                ((UIView <BulletinBoardObject> * ) sender.view).highlighted = NO;
            }
            
            if ([sender.view isKindOfClass:[NoteView class]]){
                [self updateNoteLocation:(NoteView *) sender.view];
            }
            else if ([sender.view isKindOfClass:[StackView class]]){
                StackView * stack = (StackView *) sender.view;
                for(NoteView * stackNoteView in stack.views){
                    stackNoteView.frame = stack.frame;
                    [self updateNoteLocation:stackNoteView];
                }
            }
        }
        else{
            self.editMode = YES;
            self.highlightedView = (UIView <BulletinBoardObject> *) sender.view;
            
            [self addContextualToolbarItems:sender.view];
            
            if ([sender.view conformsToProtocol:@protocol(BulletinBoardObject)]){
                ((UIView <BulletinBoardObject> * ) sender.view).highlighted = YES;
            }
        }
    }
    
}

-(void) objectPanned: (UIPanGestureRecognizer *) sender{
    
    if( sender.state == UIGestureRecognizerStateChanged ||
       sender.state == UIGestureRecognizerStateEnded){
        CGPoint translation = [sender translationInView:self.collectionView];
        UIView * pannedView = [sender view];
        CGPoint newOrigin = CGPointMake(pannedView.frame.origin.x + translation.x,
                                        pannedView.frame.origin.y + translation.y);
        pannedView.frame = CGRectMake(newOrigin.x, newOrigin.y, pannedView.frame.size.width,pannedView.frame.size.height);
        [sender setTranslation:CGPointZero inView:self.collectionView];
        
        if (self.editMode) return;
        
        self.panCounter++;
        if (self.panCounter > CHECK_TIME ){
            self.panCounter = 0;
            NSArray * intersectingViews = [self.layoutHelper checkForOverlapWithView:sender.view
                                                                    inCollectionView:self.collectionView];
            if ( [intersectingViews count] != [self.intersectingViews count] || [intersectingViews count] == 1){
                for (UIView * view in self.intersectingViews){
                    view.alpha = 1;
                }
            }
            else{
                for (UIView * view in intersectingViews){
                    
                    view.alpha = 0.5;
                }
            }
            self.intersectingViews = intersectingViews;   
        }
    }
    
    
    if (sender.state == UIGestureRecognizerStateEnded){
        BOOL frameChanged = NO;
        CGFloat newOriginX = sender.view.frame.origin.x;
        CGFloat newOriginY = sender.view.frame.origin.y;
        
        if (sender.view.frame.origin.x < self.collectionView.frame.origin.x){
            frameChanged = YES;
            newOriginX = self.collectionView.frame.origin.x;
        }
        if (sender.view.frame.origin.y < self.collectionView.frame.origin.y){
            frameChanged = YES;
            newOriginY = self.collectionView.frame.origin.y;
        }
        if (sender.view.frame.origin.x + sender.view.frame.size.width > 
            self.collectionView.frame.origin.x + self.collectionView.frame.size.width){
            frameChanged = YES;
            newOriginX = self.collectionView.frame.origin.x + self.collectionView.frame.size.width - sender.view.frame.size.width;
        }
        if (sender.view.frame.origin.y + sender.view.frame.size.height > 
            self.collectionView.frame.origin.y + self.collectionView.frame.size.height){
            frameChanged = YES;
            newOriginY = self.collectionView.frame.origin.y + self.collectionView.frame.size.height - sender.view.frame.size.height - 50;
        }
        
        if (frameChanged){
            [UIView animateWithDuration:0.1 animations:^{
                sender.view.frame = CGRectMake(newOriginX, newOriginY, sender.view.frame.size.width, sender.view.frame.size.height);
            }];
        }
        
        
        
        for (UIView * view in self.intersectingViews){
            view.alpha = 1;
        } 
        
        if ([self.intersectingViews count] > 1 ){
            [self stackNotes:self.intersectingViews into:sender.view withID:nil];
        }
        
        if([sender.view isKindOfClass:[NoteView class]]){
            [self updateNoteLocation:(NoteView *) sender.view];
        }
        else if ([sender.view isKindOfClass:[StackView class]]){
            StackView * stack = (StackView *) sender.view;
            for(NoteView * stackNoteView in stack.views){
                stackNoteView.frame = stack.frame;
                [self updateNoteLocation:stackNoteView];
            }
        }
        
        return;
    }
    
}

-(void) stackTapped: (UIPanGestureRecognizer *) sender{
    StackViewController * stackViewer = [self.storyboard instantiateViewControllerWithIdentifier:@"StackView"];
    stackViewer.delegate = self;
    stackViewer.notes = ((StackView *) sender.view).views;
    stackViewer.openStack = (StackView *) sender.view;
    [self presentViewController:stackViewer animated:YES completion:^{}];
}

-(void) objectPinched: (UIPinchGestureRecognizer *) sender{
    
//    if (self.editMode) return;
    if (sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded){
        NSLog(@"JERE");
        CGFloat scale = sender.scale;
        if ([sender.view conformsToProtocol: @protocol(BulletinBoardObject)]){
            UIView <BulletinBoardObject> * view = (NoteView *) sender.view;
            [view scale:scale];
        }
        
        sender.scale = 1 ;
    }
}

#pragma mark - UI Events

-(void) viewWillAppear:(BOOL)animated{
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
}

-(void) viewDidLoad
{
    
    int len = [[self.toolbar items] count];
    self.deleteButton = [self.toolbar items][len - 1];
    self.expandButton = [self.toolbar items][len - 2];
    NSMutableArray * toolBarItems = [[NSMutableArray alloc] init];
    
    int remainingCount = [[self.toolbar items] count] -2; 
    for ( int i = 0 ; i < remainingCount ; i++){
        [toolBarItems addObject:[self.toolbar items][i]];
    }
    self.toolbar.items = [toolBarItems copy];
    
    [super viewDidLoad];
    CGSize size =  CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    [self.collectionView setContentSize:size];
    
    UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainScreenDoubleTapped:)];
    gr.numberOfTapsRequired = 2;
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    [self.collectionView addGestureRecognizer:gr];
    [self.collectionView addGestureRecognizer:tgr];
    self.collectionView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSavedNotes:)
                                                 name:COLLECTION_RELOAD_EVENT
                                               object:self.board];
    [self layoutNotes];
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    for (UIView * view in self.collectionView.subviews){
        
        float positionX = view.frame.origin.x;
        float positionY = view.frame.origin.y;
        BOOL changed = NO;
        if ( positionX + view.frame.size.width > self.collectionView.frame.origin.x + self.collectionView.frame.size.width ){
            positionX = self.collectionView.frame.origin.x + self.collectionView.frame.size.width - NOTE_WIDTH;
            changed = YES;
        }
        if ( positionY + view.frame.size.height > self.collectionView.frame.origin.x + self.collectionView.frame.size.height){
            positionY = self.collectionView.frame.origin.x + self.collectionView.frame.size.height - NOTE_HEIGHT;
            changed = YES;
        }
        if (positionX <  self.collectionView.frame.origin.x){
            positionX = self.collectionView.frame.origin.x;
            changed = YES;
        }
        if (positionY < self.collectionView.frame.origin.y){
            positionY = self.collectionView.frame.origin.y;
            changed = YES;
        }
        
        if(changed){
            view.frame = CGRectMake(positionX, positionY, view.frame.size.width, view.frame.size.height);
        }
    }
    
}

-(void) viewDidUnload
{
    //[DropBoxAssociativeBulletinBoard saveBulletinBoard:self.board];
    
    
    [self setTitle:nil];
    [self setView:nil];
    [self setCollectionView:nil];
    [self setToolbar:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark - UI Actions

- (IBAction)cameraPressed:(id)sender {
    
    //check to see if camera is available
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        return;
    }
    
    NSArray * mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    if (![mediaTypes containsObject:(NSString *) kUTTypeImage]) return;
    
    UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:^{}];
}


-(IBAction) expandPressed:(id) sender {
    if (!self.editMode) return;
    
    if (![self.highlightedView isKindOfClass:[StackView class]]) return;
    
    
    if ([self.highlightedView isKindOfClass:[StackView class]])
    {
        CGRect fittingRect = [self.layoutHelper findFittingRectangle: (StackView *) self.highlightedView
                              inView:self.collectionView];
        
        //move stuff that is in the rectangle out of it
        [self.layoutHelper clearRectangle: fittingRect
                         inCollectionView:self.collectionView
                     withMoveNoteFunction:^(NoteView * note){
                         [self updateNoteLocation:note];
                     }];
        
        //layout stack in the empty rect
        [self layoutStackView:(StackView *) self.highlightedView inRect:fittingRect ];
        
        //clean up
        [self removeContextualToolbarItems:self.highlightedView];
        [self.board removeBulletinBoardAttribute:((StackView *)self.highlightedView).ID ofType:STACKING_TYPE];
        self.highlightedView = nil;
        self.editMode = NO;
        
    }
    
    
}

-(IBAction) deletePressed:(id) sender {
    if(!self.editMode) return;
    
    
    [self removeContextualToolbarItems:self.highlightedView];
    
    if ([self.highlightedView isKindOfClass:[StackView class]]){
        
        [self.board removeBulletinBoardAttribute:((StackView *) self.highlightedView).ID ofType:STACKING_TYPE];
        
        for (UIView * view in ((StackView *) self.highlightedView).views){
            [view removeFromSuperview];
            [self.board removeNoteWithID:((NoteView *)view).ID];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.highlightedView.transform = CGAffineTransformScale(self.highlightedView.transform, 0.05, 0.05);
        }completion:^ (BOOL didFinish){
            [self.highlightedView removeFromSuperview];
            self.editMode = NO;
            self.highlightedView = nil;
        }];
    }
    else if ([self.highlightedView isKindOfClass:[NoteView class]]){
        
        [UIView animateWithDuration:0.5 animations:^{
            self.highlightedView.transform = CGAffineTransformScale(self.highlightedView.transform, 0.05, 0.05);
        }completion:^ (BOOL didFinish){
            [self.highlightedView removeFromSuperview];
            [self.board removeNoteWithID:(self.highlightedView.ID)];
            self.editMode = NO;
            self.highlightedView = nil;
        }];
    }
    
    
    
}

-(IBAction)backPressed:(id) sender {
    
    //save the bulletinboard
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.board cleanUp];
    [self.parent finishedWorkingWithBulletinBoard];
}


- (IBAction)refreshPressed:(id)sender {
    
    if (self.isRefreshing) return;
    
    self.isRefreshing = YES;
    self.board = [[MindcloudCollection alloc] initCollection:self.bulletinBoardName
                                               withDataSource:[[CachedMindCloudDataSource alloc] init]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSavedNotes:)
                                                 name:COLLECTION_RELOAD_EVENT
                                               object:self.board];
}


#pragma mark - stack delegate methods
-(void) returnedstackViewController:(StackViewController *)sender{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

-(void) unstackItem:(UIView *) item
           fromView: (UIView *) stackView 
      withPastCount: (int) count{
    
    if ( [item isKindOfClass:[NoteView class]]){
        NoteView * noteItem = (NoteView *) item;
        
        if (((StackView *) stackView).mainView == noteItem){
            [((StackView *) stackView) setNextMainView];
        }
        for (UIGestureRecognizer * gr in noteItem.gestureRecognizers){
            [noteItem removeGestureRecognizer:gr];
        }
        
        UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectPanned:)];
        UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(objectPinched:)];
        UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(objectPressed:)];
        
        [noteItem addGestureRecognizer:lpgr];
        [noteItem addGestureRecognizer:gr];
        [noteItem addGestureRecognizer:pgr];
        
        noteItem.delegate = self;
        [noteItem resetSize];
        
        [noteItem resetSize];
        float offset = SEPERATOR_RATIO * noteItem.frame.size.width;
        CGRect tempRect = CGRectMake (self.collectionView.frame.origin.x + offset,
                                      self.collectionView.frame.origin.y + self.collectionView.frame.size.height - (noteItem.frame.size.height + offset),
                                      noteItem.frame.size.width,
                                      noteItem.frame.size.height);
        noteItem.frame = tempRect;
        [self.collectionView addSubview:noteItem];
        [UIView animateWithDuration:0.5 animations:^{ noteItem.alpha = 1;} completion:^(BOOL isFinished){
            CGRect finalRect = CGRectMake(stackView.frame.origin.x + (count * offset * 2), 
                                          stackView.frame.origin.y + (count * offset * 2), 
                                          noteItem.frame.size.width,
                                          noteItem.frame.size.height);
            [UIView animateWithDuration:1 animations:^{noteItem.frame = finalRect;}];
            
            [self.board removeNote:noteItem.ID fromBulletinBoardAttribute:((StackView*) stackView).ID ofType:STACKING_TYPE];
            [self updateNoteLocation:noteItem];
        }];
        
    }
}

#pragma mark - note delegate
- (void) note: (id)note changedTextTo: (NSString *) text{
    
    NoteView * noteView = (NoteView *)note;
    NSString * noteId = noteView.ID;
    CollectionNote * newNoteObj = [[CollectionNote alloc] initWithText:text];
    [self.board updateNoteContentOf:noteId withContentsOf:newNoteObj];
}

-(void) resignFirstResponders{
    for(UIView * view in self.collectionView.subviews){
        if ([view conformsToProtocol:@protocol(BulletinBoardObject)]){
            id<BulletinBoardObject> obj = (id<BulletinBoardObject>) view;
            [obj resignFirstResponder];
        }
    }
}

#pragma mark - image delegate
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}


-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [self dismissModalViewControllerAnimated:YES];
    CGRect frame = CGRectMake(self.collectionView.frame.origin.x,
                              self.collectionView.frame.origin.y,
                              NOTE_WIDTH, 
                              NOTE_HEIGHT);
    
    ImageView * note = [[ImageView alloc] initWithFrame:frame 
                                               andImage:image];
    
    note.transform = CGAffineTransformScale(note.transform, 10, 10);
    note.alpha = 0;
    note.delegate = self;
    
    [UIView animateWithDuration:0.25 animations:^{
        note.transform = CGAffineTransformScale(note.transform, 0.1, 0.1);
        note.alpha = 1;
    }];
    
    [self.collectionView addSubview:note];
    UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectPanned:)];
    UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(objectPinched:)];
    UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(objectPressed:)];
    
    [note addGestureRecognizer:lpgr];
    [note addGestureRecognizer:gr];
    [note addGestureRecognizer:pgr];
    
    [self addImageNoteToModel: note];

}

@end
