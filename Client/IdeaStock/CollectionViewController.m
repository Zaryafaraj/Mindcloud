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
#import "CachedCollectionDataSource.h"

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

@end

#pragma mark - Definitions

#define NOTE_WIDTH 200
#define NOTE_HEIGHT 200
#define STACKING_SCALING_WIDTH 1.1
#define STACKING_SCALING_HEIGHT 1.05
#define POSITION_X_TYPE @"positionX"
#define POSITION_Y_TYPE @"positionY"
#define POSITION_TYPE @"position"
#define STACKING_TYPE @"stacking"
//0 is the max
#define IMG_COMPRESSION_QUALITY 0.5
#define EXPAND_COL_SIZE 5
#define SEPERATOR_RATIO 0.1
#define EXIT_OFFSET_RATIO 0.1
#define OVERLAP_RATIO 0.35
#define CHECK_TIME 0

@implementation CollectionViewController

#pragma mark - getter/setters
-(MindcloudCollection *) board{
    
    if (!_board){
        _board = [[MindcloudCollection alloc] initCollection:self.bulletinBoardName
                                              withDataSource:[CachedCollectionDataSource getInstance]];
    }
    return _board;
}

#pragma mark - UI Helpers
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

#pragma mark - Stacking Actions
/*
 If ID is nil the methods will create a unique UUID itself and will also write
 to the datamodel. 
 If ID is not nil the stacking this means that stacking is formed from the datamodel
 */
//TODO bad function design , this should be broken down into two things
-(void) stackNotes: (NSArray *) items into: (UIView *) mainView withID: (NSString *) ID{
    __block BOOL first = YES;
    
    CGRect stackFrame;
    if (first){
        if ([mainView isKindOfClass:[NoteView class]]){
            stackFrame = CGRectMake(mainView.frame.origin.x - ((STACKING_SCALING_WIDTH -1)/4) * mainView.frame.origin.x,
                                    mainView.frame.origin.y - ((STACKING_SCALING_HEIGHT -1)/4) * mainView.frame.origin.y,
                                    mainView.bounds.size.width * STACKING_SCALING_WIDTH,
                                    mainView.bounds.size.height * STACKING_SCALING_HEIGHT );
        }
        else if ([mainView isKindOfClass:[StackView class]]){
            stackFrame = mainView.frame;
        }
    }
    
    NSMutableArray * allNotes = [self getAllNormalNotesInViews:items];
    NSString * stackingID ;
    
    if (!ID){
        stackingID = [self normalizeStackingWithItems: (NSArray *)items 
                                          andMainView: (UIView *) mainView];
    }
    else{
        stackingID = ID;
    }
    StackView * stack = [[StackView alloc] initWithViews:allNotes
                                             andMainView:(NoteView *)mainView
                                               withFrame:
                         stackFrame];
    [UIView animateWithDuration:0.5 animations:^{mainView.alpha = 0;}];
    [mainView removeFromSuperview];
    mainView.alpha = 1;
    stack.alpha =0;
    stack.ID = stackingID;
    UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectPanned:)];
    UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(objectPinched:)];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stackTapped:)];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(objectPressed:)];
    [stack addGestureRecognizer:gr];
    [stack addGestureRecognizer:pgr];
    [stack addGestureRecognizer:tgr];
    [stack addGestureRecognizer:lpgr];
    [self.collectionView addSubview:stack];
    [UIView animateWithDuration:0.5 animations:^{stack.alpha = 1;}];
    
    
    for (UIView * view in items){
        if (view != mainView){
            [UIView animateWithDuration:0.5
                                  delay:0 options:UIViewAnimationCurveEaseOut
                             animations:^{
                                 [view setFrame:mainView.frame];
                             }
                             completion:^(BOOL finished){
                                 if ([view isKindOfClass:[NoteView class]]){
                                     if (!ID){
                                         [self updateNoteLocation:(NoteView *) view];
                                     }
                                 }
                                 [view removeFromSuperview];
                            }];
        }
    }    
}

-(NSString *) normalizeStackingWithItems: (NSArray *)items andMainView: (UIView *) mainView{
    NSString * stackingID = [XoomlAttributeHelper generateUUID];
    
    NSMutableArray * stackingNoteIDs = [[NSMutableArray alloc] init];
    for( UIView * view in items){
        if ([view isKindOfClass:[NoteView class]]){
            [stackingNoteIDs addObject:((NoteView *) view).ID];
        }
        else if ([view isKindOfClass:[StackView class]]){
            NSString * oldStackingID = ((StackView *)view).ID;
            [self.board removeBulletinBoardAttribute:oldStackingID ofType:STACKING_TYPE];
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
    
    if (topItemID == nil) return stackingID ;
    [stackingNoteIDs removeObject:topItemID];
    [stackingNoteIDs insertObject:topItemID atIndex:0];
    
    for(NSString * noteID in stackingNoteIDs){
        
        [self.board addNoteWithID:noteID toBulletinBoardAttribute:stackingID forAttributeType:STACKING_TYPE];
    }
    
    return stackingID;
}

#pragma mark - Note Actions
-(NSString *) addNoteToModel: (NoteView *) note{
    
    NSString * noteTextID = [XoomlAttributeHelper generateUUID];
    NSString * creationDate = [XoomlAttributeHelper generateCurrentTimeForXooml];
    NSString * noteID = [XoomlAttributeHelper generateUUID];
    
    NSString * noteName = [NSString stringWithFormat:@"Note%d",self.noteCount];
    self.noteCount++;
    NSString * positionX = [NSString stringWithFormat:@"%f", note.frame.origin.x];
    NSStream * positionY = [NSString stringWithFormat:@"%f", note.frame.origin.y];
    
    NSDictionary * noteProperties =@{@"name": noteName,@"ID": noteID,@"positionX": positionX,@"positionY": positionY,@"isVisible": @"true"};
    CollectionNote * noteItem = [[CollectionNote alloc] initEmptyNoteWithID:noteTextID andDate:creationDate];
    noteItem.noteText = note.text;
    
    [self.board addNoteContent:noteItem andProperties:noteProperties];
    note.ID = noteID;
    
    return noteID;
}

-(NSString *) addImageNoteToModel: (ImageView *) note{
    
    NSString * noteTextID = [XoomlAttributeHelper generateUUID];
    NSString * creationDate = [XoomlAttributeHelper generateCurrentTimeForXooml];
    NSString * noteID = [XoomlAttributeHelper generateUUID];
    
    NSString * noteName = [NSString stringWithFormat:@"Note%d",self.noteCount];
    self.noteCount++;
    NSString * positionX = [NSString stringWithFormat:@"%f", note.frame.origin.x];
    NSStream * positionY = [NSString stringWithFormat:@"%f", note.frame.origin.y];
    
    NSDictionary * noteProperties =@{@"name": noteName,@"ID": noteID,@"positionX": positionX,@"positionY": positionY,@"isVisible": @"true"};
    CollectionNote * noteItem = [[CollectionNote alloc] initEmptyNoteWithID:noteTextID andDate:creationDate];
    noteItem.noteText = note.text;
    NSData * imgData = UIImageJPEGRepresentation(note.image, IMG_COMPRESSION_QUALITY);
    
    [self.board addImageNoteContent:noteItem andProperties:noteProperties andImage: imgData];
    
    note.ID = noteID;
    
    return noteID;
}

-(void) updateNoteLocation:(NoteView *) view{
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
    
    [self.board updateNoteAttributes:noteID withAttributes:newProperties]; 
}


- (NSMutableArray *) getAllNormalNotesInViews: (NSArray *) views{
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
    

    NSLog(@"Reading Bulletinboard data from the filesytem");
    NSLog(@"----------------------------");
    [self layoutNotes];
}

#pragma mark - Layout

-(void) layoutNotes{
    
    NSLog(@"Laying out Notes");
    for(UIView * view in self.collectionView.subviews){
        [view removeFromSuperview];
    }
    NSDictionary * allNotes = [self.board getAllNotes];
    NSDictionary * allImgs = [self.board getAllNoteImages];
    NSLog(@"Read %d image", [allImgs count]);
    self.noteCount = [allNotes count];
    NSLog(@"Read %d notes",[allNotes count]);
    
    
    for(NSString* noteID in [allNotes allKeys]){
        CollectionNote * noteObj = allNotes[noteID];
        NSDictionary * noteAttributes = [self.board getAllNoteAttributesForNote:noteID];
        NSDictionary * position = noteAttributes[@"position"];
        float positionX = [[position[@"positionX"] lastObject] floatValue];
        float positionY = [[position[@"positionY"] lastObject] floatValue];
        
        if ( positionX + NOTE_WIDTH > self.collectionView.frame.origin.x + self.collectionView.frame.size.width ){
            positionX = self.collectionView.frame.origin.x + self.collectionView.frame.size.width - NOTE_WIDTH;
        }
        if ( positionY + NOTE_HEIGHT > self.collectionView.frame.origin.x + self.collectionView.frame.size.height){
            positionY = self.collectionView.frame.origin.x + self.collectionView.frame.size.height - NOTE_HEIGHT;
        }
        if (positionX <  self.collectionView.frame.origin.x){
            positionX = self.collectionView.frame.origin.x;
        }
        if (positionY < self.collectionView.frame.origin.y){
            positionY = self.collectionView.frame.origin.y;
        }
        
        CGRect noteFrame = CGRectMake(positionX, positionY, NOTE_WIDTH, NOTE_HEIGHT); NoteView * note ;
        
        if (allImgs[noteID]){
            UIImage * img = [[UIImage alloc] initWithData:allImgs[noteID]];
            note = [[ImageView alloc] initWithFrame:noteFrame 
                                                    andImage:img];
        }
        else{
            note = [[NoteView alloc] initWithFrame:noteFrame];
        }

        if (noteObj.noteText) note.text = noteObj.noteText;
        note.transform = CGAffineTransformScale(note.transform, 10, 10);
        note.alpha = 0;
        note.ID = noteID;
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
        
        
    }
    
    [self layoutStackings];
}

-(void) layoutStackings{
    NSLog(@"Laying Stackings");
    NSDictionary * stackings =[self.board getAllBulletinBoardAttributeNamesOfType:STACKING_TYPE];
    for (UIView * view in self.collectionView.subviews){
        NSLog(@"%@",view);
        if ([view isKindOfClass:[StackView class]]){
            NSLog(@"Removing Stacking");
            [view removeFromSuperview ];
        }
    }
    NSLog(@"Stackings loaded : %@", stackings);
    int count = 1;
    for(NSString * stackingID in stackings){
        NSLog(@"%d",count);
        count++;
        NSMutableArray * views = [[NSMutableArray alloc] init];
        NSArray * noteRefIDs = stackings[stackingID];
        NSSet * noteRefs = [[NSSet alloc] initWithArray:noteRefIDs];
        UIView * mainView;
        for (UIView * view in self.collectionView.subviews){
            if ([view isKindOfClass:[NoteView class]]){
                NSString * noteID = ((NoteView *) view).ID;
                if ([noteRefs containsObject:noteID]){
                    [views addObject:view];
                    if ([noteID isEqualToString:noteRefIDs[0]]){
                        mainView = view;
                    }
                }
            }
        }
        
        
        
        [self stackNotes:views into:mainView withID:stackingID];
    }
    
        self.isRefreshing = NO;
}

-(CGSize) getRectSizeForStack: (StackView *) stack{
    
    int notesInStack = [stack.views count];
    
    //get the number of rows in expanded state
    int numberOfRows = notesInStack / EXPAND_COL_SIZE;
    if (notesInStack % EXPAND_COL_SIZE != 0 ) numberOfRows++;
    
    //get a single note size from the main note in stack
    NoteView * dummyNote = ((NoteView *)[stack.views lastObject]);
    [dummyNote resetSize];
    float noteWidth = dummyNote.bounds.size.width ;
    float noteHeight = dummyNote.bounds.size.height ;
    
    //calculate the rectangle size before adding seperators
    int rowItems = notesInStack >= EXPAND_COL_SIZE ? EXPAND_COL_SIZE : notesInStack;
    float seperatorSpace = MAX(noteWidth,noteHeight) * SEPERATOR_RATIO;
    float rectWidth = noteWidth + ( (noteWidth/3) * (rowItems - 1)) + ((numberOfRows) * seperatorSpace);
    float rectHeight= (2* seperatorSpace) + noteHeight + ( (noteHeight/3) * (numberOfRows - 1));
    
    //add seperator sizes
    // float biggerSize = MAX(rectWidth, rectHeight);
    // float seperatorSize = SEPERATOR_RATIO * biggerSize;
    //rectWidth += (EXPAND_COL_SIZE + 1) * seperatorSize;
    //rectHeight += (numberOfRows + 1) * seperatorSize;
    
    return CGSizeMake(rectWidth, rectHeight);
}

-(CGRect) findFittingRectangle: (StackView *) stack{
    
    //find the size
    CGSize rectSize = [self getRectSizeForStack:stack];
    
    //now find the starting position
    float stackMiddleX = stack.frame.origin.x + stack.frame.size.width/2;
    float stackMiddleY = stack.frame.origin.y + stack.frame.size.height/2;
    
    //first find the starting x
    float startX = 0;
    float startY = 0;
    if (stackMiddleX + rectSize.width/2 > self.collectionView.bounds.origin.x + self.collectionView.bounds.size.width){
        //rect goes out of the right side of screen so fit it in a way that the right side of rect is on the right side of 
        //the screen
        startX = (self.collectionView.bounds.origin.x + self.collectionView.bounds.size.width) - rectSize.width;
    }
    else if (stackMiddleX - rectSize.width/2 < self.collectionView.bounds.origin.x){
        //rect goes out of the left side of screen so fit it in a way that the left side of rect is on the left side of 
        //the screen
        startX = self.collectionView.bounds.origin.x;
    }
    else{
        //rect fits around the stack 
        startX = stackMiddleX - rectSize.width/2;
    }
    
    //do the same thing to find starting y
    if (stackMiddleY + rectSize.height/2 > self.collectionView.bounds.origin.y + self.collectionView.bounds.size.height){
        startY  = (self.collectionView.bounds.origin.y + self.collectionView.bounds.size.height) - rectSize.height;
    }
    else if (stackMiddleY - rectSize.height/2 < self.collectionView.bounds.origin.y){
        startY = self.collectionView.bounds.origin.y;
    }
    else {
        startY = stackMiddleY - rectSize.height/2;
    }
    
    return CGRectMake(startX, startY, rectSize.width, rectSize.height);
}

-(void) clearRectangle: (CGRect) rect{
    for (UIView * subView in self.collectionView.subviews){
        if ([subView conformsToProtocol:@protocol(BulletinBoardObject)]){
            if (CGRectIntersectsRect(subView.frame, rect)){
                
                float newStartX = subView.frame.origin.x;
                float newStartY = subView.frame.origin.y;
                
                float offsetX = EXIT_OFFSET_RATIO * subView.frame.size.width;
                float offsetY = EXIT_OFFSET_RATIO * subView.frame.size.height;
                
                //find the closest point for the view to exit
                float rectMid = rect.origin.x + rect.size.width/2;
                if (subView.frame.origin.x < rectMid){
                    //view is in the left side of the rect 
                    //find the distance to move the view come out of the rect
                    //it will first try to see if the view fits the screen if it exits from the right side rect
                    //if this is not possible it tries the lower side of the rect and if that doesnt work either
                    //it should definetly fit the top side ( given that the rect is not bigger than the screen)
                    //we try each case in order
                    
                    //first the left side. This distance is the distance between the left edge of the rect and the right edge of view
                    float distanceToExitX = (subView.frame.origin.x + subView.frame.size.width + offsetX) - rect.origin.x;
                    
                    //check to see if traveling this distance makes the subView fall out of screen on the left side
                    if ( subView.frame.origin.x - distanceToExitX > self.collectionView.bounds.origin.x){
                        //the view doesn't fall out of the screen so move make its starting point there 
                        newStartX = subView.frame.origin.x - distanceToExitX;
                    }
                    else{
                        //the view falls out of the screen if we move left, try moving down
                        //the distance is between the top edge of the subview and low buttom of the rect
                        float distanceToExitY = (rect.origin.y + rect.size.height + offsetY) - (subView.frame.origin.y);
                        if (subView.frame.origin.y + subView.frame.size.height +distanceToExitY < self.collectionView.bounds.origin.y + self.collectionView.bounds.size.height){
                            //the view can be fit outside the lower edge of the rect
                            newStartY = subView.frame.origin.y + distanceToExitY;
                        }
                        else {
                            //the view cannot be fit in the left side of rect or the down side of the rect, surely it can fit in the upper side of the rect
                            //find the distance to exit from the top side. the distance is between the low edge of the view and the top edge of the rect
                            distanceToExitY = (subView.frame.origin.y + subView.frame.size.height + offsetY) - rect.origin.y;
                            newStartY = subView.frame.origin.y - distanceToExitY;
                        }
                    }
                    
                }
                
                
                //we follow the same algorithm if the view is in the right side of the rect
                else {
                    
                    //try the rightside. The distance is between the right edge of rect and left edge of view
                    float distanceToExitX = (rect.origin.x + rect.size.width + offsetX) - (subView.frame.origin.x );
                    if (subView.frame.origin.x + subView.frame.size.width + distanceToExitX < self.collectionView.bounds.origin.x + self.collectionView.bounds.size.width){
                        //fits in the right side 
                        newStartX = subView.frame.origin.x + distanceToExitX;
                    }
                    else{
                        //try the lower side
                        float distanceToExitY = (rect.origin.y + rect.size.height + offsetY) - (subView.frame.origin.y);
                        if (subView.frame.origin.y +subView.frame.size.height + distanceToExitY < self.collectionView.bounds.origin.y + self.collectionView.bounds.size.height){
                            newStartY = subView.frame.origin.y + distanceToExitY;
                        }
                        else{
                            //use the top side
                            distanceToExitY = (subView.frame.origin.y + subView.frame.size.height + offsetY) - rect.origin.y;
                            newStartY = subView.frame.origin.y - distanceToExitY;
                        }
                    }
                }
                
                [UIView animateWithDuration:0.25 animations:^{subView.frame = CGRectMake(newStartX, newStartY, subView.frame.size.width, subView.frame.size.height);}];
                if ([subView isKindOfClass:[NoteView class]]){
                    [self updateNoteLocation: (NoteView *) subView];
                }
                else if ([subView isKindOfClass:[StackView class]]){
                    StackView * stack = (StackView *) subView;
                    for(NoteView * stackNoteView in stack.views){
                        stackNoteView.frame = stack.frame;
                        [self updateNoteLocation:stackNoteView];
                    }
                }
                
            }
        }
    }
}

-(void) layoutStackView: (StackView *) stack inRect: (CGRect) rect{
    
    NSArray * items = stack.views;
    
    //now find the size of the seperator from any note
    [((NoteView *) [items lastObject]) resetSize];
    float noteWidth = ((NoteView *)[items lastObject]).frame.size.width  ;
    float noteHeight = ((NoteView *)[items lastObject]).frame.size.height;
    
    //remove all existing gesture recognizers and add the new ones. 
    //finally position all the notes in the center of the stackView
    for (NoteView * view in items){
        for (UIGestureRecognizer * gr in view.gestureRecognizers){
            [view removeGestureRecognizer:gr];
        }
        UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectPanned:)];
        UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(objectPinched:)];
        UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(objectPressed:)];
        
        [view addGestureRecognizer:lpgr];
        [view addGestureRecognizer:gr];
        [view addGestureRecognizer:pgr];
        
        view.delegate = self;
        [view resetSize];
        [view removeFromSuperview];
        [self.collectionView addSubview:view];
        CGRect viewTempFrame = CGRectMake(stack.frame.origin.x, stack.frame.origin.y, view.frame.size.width, view.frame.size.height);
        view.frame = viewTempFrame;
        
        
    }
    
    //now remove the stack itself
    [UIView animateWithDuration:0.25 animations:^{ stack.alpha = 0 ;} completion:^(BOOL finished){[stack removeFromSuperview];}];
    
    
    float seperator = SEPERATOR_RATIO * MAX(noteWidth, noteHeight);
    
    float startX = rect.origin.x + seperator;
    float startY = rect.origin.y + seperator;
    
    int rowCount = 0;
    int colCount = 0;
    for (NoteView * view in items){
        [UIView animateWithDuration:0.5 animations:^{view.frame = CGRectMake(startX, startY, view.frame.size.width, view.frame.size.height);}];
        rowCount++;
        if (rowCount >= EXPAND_COL_SIZE){
            rowCount = 0;
            colCount++;
            startX = rect.origin.x + seperator * (colCount+1);
            startY += noteHeight/3;
        }
        else{
            startX += noteWidth/3;
        }
        [self updateNoteLocation:view];   
    }
}

-(BOOL) does: (UIView *) view1 OverlapWithView: (UIView *) view2{
    
    CGPoint view1Center = CGPointMake(view1.frame.origin.x + (view1.frame.size.width/2), 
                                        view1.frame.origin.y + (view1.frame.size.height/2) );
    CGPoint view2Center = CGPointMake(view2.frame.origin.x + (view2.frame.size.width/2), 
                                      view2.frame.origin.y + (view2.frame.size.height/2) );
    
    CGFloat dx = view1Center.x - view2Center.x;
    CGFloat dy = view1Center.y - view2Center.y;
    
    float distance = sqrt(dx*dx + dy*dy);
    if ( distance < OVERLAP_RATIO * NOTE_WIDTH){
        return YES;
    }
    return NO;
                    
}
    
-(NSArray *) checkForOverlapWithView: (UIView *) senderView{
    NSMutableArray * ans = [[NSMutableArray alloc] init];
    for (UIView * view in self.collectionView.subviews){
        if (view != senderView && [view conformsToProtocol:@protocol(BulletinBoardObject)]){
            
            if ([self does:view OverlapWithView:senderView]){
                [ans addObject:view];
                
            }
        }
    }
    [ans addObject:senderView];
    return ans;
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
            NSArray * intersectingViews = [self checkForOverlapWithView:sender.view];
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
    /*  UIImage * image = [UIImage imageNamed:@"greenchalkboard.jpg"];
     UIColor * color = [UIColor colorWithPatternImage:image];*/
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
                                                 name:@"BulletinBoardLoaded" 
                                               object:self.board];
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
    
    [self.board cleanUp];
    
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
    
    
    CGRect fittingRect = [self findFittingRectangle: (StackView *) self.highlightedView];
    
    //move stuff that is in the rectangle out of it
    [self clearRectangle: fittingRect];
    
    //layout stack in the empty rect
    [self layoutStackView:(StackView *) self.highlightedView inRect:fittingRect ];
    
    //clean up
    [self removeContextualToolbarItems:self.highlightedView];
    [self.board removeBulletinBoardAttribute:((StackView *)self.highlightedView).ID ofType:STACKING_TYPE];
    self.highlightedView = nil;
    self.editMode = NO;
    
    
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
    
    [self.parent finishedWorkingWithBulletinBoard];
}


- (IBAction)refreshPressed:(id)sender {
    
    if (self.isRefreshing) return;
    
    self.isRefreshing = YES;
    self.board = [[MindcloudCollection alloc] initCollection:self.bulletinBoardName
                                               withDataSource:[[CachedCollectionDataSource alloc] init]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSavedNotes:)
                                                 name:@"BulletinBoardLoaded" 
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
