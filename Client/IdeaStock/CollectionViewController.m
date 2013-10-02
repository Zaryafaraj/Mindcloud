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
#import "AttributeHelper.h"
#import "ImageNoteView.h"
#import "CachedMindCloudDataSource.h"
#import "EventTypes.h"
#import "CollectionLayoutHelper.h"
#import "CollectionAnimationHelper.h"
#import "MultimediaHelper.h"
#import "NamingHelper.h"
#import "StackViewController.h"

@interface CollectionViewController ()

#pragma mark - UI Elements
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem * deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem * expandButton;
@property (weak, nonatomic) IBOutlet UIScrollView *collectionView;
@property (strong, nonatomic) NSMutableDictionary * noteViews;
@property (strong, nonatomic) NSMutableDictionary * imageNoteViews;
@property (strong, nonatomic) NSMutableDictionary * stackViews;
//@property (strong, nonatomic) UIImage * lastImageTaken;
//@property (strong, nonatomic) NSString * lastImageTakenNoteId;
@property int noteCount;
@property (strong, nonatomic) NSArray * intersectingViews;
@property (weak, nonatomic) UIView<BulletinBoardObject> * highlightedView;
@property (nonatomic) BOOL editMode;
@property int panCounter ;
@property BOOL isRefreshing;
@property BOOL shouldRefresh;
@property UIActionSheet * activeImageSheet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong, nonatomic) UIPopoverController * lastPopOver;

//we remove this prototype view from the super view at the begining of
//when the contoller loads. So we need a strong pointer to it so that it
//doesn't go out of scope
@property (strong, nonatomic) IBOutlet NoteView *prototypeNoteView;
@property (strong, nonatomic) IBOutlet ImageNoteView *prototypeImageView;

@end

#pragma mark - Definitions

#define POSITION_X_TYPE @"positionX"
#define POSITION_Y_TYPE @"positionY"
#define NOTE_SCALE_TYPE @"scale"
#define POSITION_TYPE @"position"
#define STACKING_TYPE @"stacking"
#define IMAGE_OFFSET_X 10
#define IMAGE_OFFSET_Y 10

//0 is the max
#define IMG_COMPRESSION_QUALITY 0.5
#define CHECK_TIME 0

@implementation CollectionViewController

@synthesize activeView = _activeField;
#pragma mark - getter/setters

-(MindcloudCollection *) board{
    
    if (!_board){
        _board = [[MindcloudCollection alloc] initCollection:self.bulletinBoardName];
    }
    return _board;
}


#pragma mark - Notifications

-(void) loadSavedNotes: (NSNotification *) notificatoin{
    NSLog(@"Reloading collection");
    [self clearView];
    [self layoutNotes];
}

-(void) noteImageReady:(NSNotification *) notification{
    NSDictionary * userInfo = [notification userInfo];
    NSDictionary * resultDict = userInfo[@"result"];
    NSString * collectionName = resultDict[@"collectionName"];
    if ([collectionName isEqual:self.bulletinBoardName])
    {
        NSString * noteId = resultDict[@"noteId"];
        if (self.imageNoteViews[noteId])
        {
            ImageNoteView * imgView =  self.imageNoteViews[noteId];
            NSData * imgData = [self.board getImageForNote:noteId];
            imgView.image = [UIImage imageWithData:imgData];
            
        }
    }
}
-(void) ApplicationHasGoneInBackground:(NSNotification *) notification
{
    [self.board pause];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) applicationWillEnterForeground:(NSNotification *) notification
{
    [self.board refresh];
}

#pragma mark - Listener Notifications
-(void) addListenerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteImageAddedEventOccured:)
                                                 name:ASSOCIATION_WITH_IMAGE_ADDED_EVENT
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteAddedEventOccured:)
                                                 name:ASSOCIATION_ADDED_EVENT
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteContentUpdateEventOccured:)
                                                 name:ASSOCIATION_CONTENT_UPDATED_EVENT
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteImageUpdateEventOccured:)
                                                 name:ASSOCIATION_IMAGE_UPDATED_EVENT
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteUpdatedEventOccured:)
                                                 name:ASSOCIATION_UPDATED_EVENT
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteDeletedEventOccured:)
                                                 name:ASSOCIATION_DELETED_KEY
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stackAddedEventOccured:)
                                                 name:STACK_ADDED_EVENT
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stackUpdatedEventOccured:)
                                                 name:STACK_UPDATED_EVENT
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stackDeletedEventOccured:)
                                                 name:STACK_DELETED_EVENT
                                               object:self.board];
}

-(void) noteAddedEventOccured:(NSNotification *) notification
{
    NSDictionary * userInfo = notification.userInfo;
    NSArray * result = userInfo[@"result"];
    for (NSString * noteId in result)
    {
        CollectionNote * noteObj = [self.board getNoteContent:noteId];
        CollectionNoteAttribute * noteModel = [self.board getNoteModelFor:noteId];
        
        if (noteObj == nil || noteModel == nil) break;
        
        NoteView * noteView =[self addNote:noteId
                       toViewWithNoteModel:noteModel
                            andNoteContent:noteObj];
        //NSLog(@"text: %@", noteObj.noteText);
        
        //if the note belongs to a stacking view make sure that we update it
        [self updateStackingViewsIfNecessaryForNoteWithId:noteId
                                              andNoteView:noteView];
        
        self.noteCount++;
    }
}

-(void) updateStackingViewsIfNecessaryForNoteWithId:(NSString *) noteId
                                        andNoteView:(NoteView *) noteView
{
    NSString * noteStackingId = [self.board stackingForNote:noteId];
    
    if (noteStackingId == nil) return;
    
    StackView * stackView = self.stackViews[noteStackingId];
    
    if (stackView == nil) return;
    
    [stackView addNoteView:noteView];
    
    [self updatePresentingStackViewControllerIfNecessaryForStackView:stackView];
}

-(void) updatePresentingStackViewControllerIfNecessaryForStackView: (StackView *) stackView
{
    //if we are currently showing the stack view that just got updated, redraw it
    if ([self.presentedViewController isKindOfClass:[StackViewController class]])
    {
        StackViewController * openStackController = (StackViewController *) self.presentedViewController;
        if (openStackController.openStack == stackView)
        {
            [openStackController refresh];
        }
    }
}

-(void) noteImageAddedEventOccured:(NSNotification *) notification
{
    NSDictionary * userInfo = notification.userInfo;
    NSArray * result = userInfo[@"result"];
    for(NSString * noteId in result)
    {
        NSLog(@"CollectionViewController: Image Added Event Received for %@", noteId);
        CollectionNote * noteObj = [self.board getNoteContent:noteId];
        CollectionNoteAttribute * noteModel = [self.board getNoteModelFor:noteId];
        
        if (noteObj == nil || noteModel == nil) break;
        
        NoteView * note = [self addNote:noteId
                    toViewWithNoteModel:noteModel
                         andNoteContent:noteObj];
        
        self.noteViews[noteId] = note;
        if ([note isKindOfClass:[ImageNoteView class]])
        {
            NSData * imgData = [self.board getImageForNote:noteId];
            ((ImageNoteView *) note).image = [UIImage imageWithData:imgData];
            self.imageNoteViews[noteId] = note;
        }
        
        [self updateStackingViewsIfNecessaryForNoteWithId:noteId
                                              andNoteView:note];
        self.noteCount++;
    }
}

-(NoteView *) getNoteView:(NSString *) noteId
{
    NoteView * noteView = self.noteViews[noteId];
    if (noteView == nil)
    {
        noteView = self.imageNoteViews[noteId];
    }
    return noteView;
}

-(void) noteUpdatedEventOccured:(NSNotification *) notification
{
    
    NSDictionary * userInfo = notification.userInfo;
    NSArray * result = userInfo[@"result"];
    for(NSString * noteId in result)
    {
        NSLog(@"CollectionViewController: Note Updated Event Received for %@", noteId);
        CollectionNoteAttribute * noteModel = [self.board getNoteModelFor:noteId];
        NoteView * noteView = [self getNoteView:noteId];
        if (noteView == nil) break;
        
        float positionX = [noteModel.positionX floatValue];
        float positionY = [noteModel.positionY floatValue];
        float scale = [noteModel.scaling floatValue];
        
        //make sure that the positions are in the bounds of the screen
        [CollectionLayoutHelper adjustNotePositionsForX:&positionX
                                                   andY:&positionY
                                                 inView:self.collectionView];
        
        //if the updated note is part of a stack we need to move the stack with the note too
        NSString * noteStackingId = [self.board stackingForNote:noteId];
        UIView <BulletinBoardObject> * view = noteStackingId != nil ? self.stackViews[noteStackingId] : noteView;
        if (noteStackingId)
        {
            
        NSLog(@"CollectionViewController: Note%@ is part of stacking %@; updating stacking", noteId, noteStackingId);
            
        }
        
        //if the note is still attached to a stack view
        if (view == noteView && noteView.superview != self.collectionView)
        {
            [noteView removeFromSuperview];
            [self sanitizeNoteViewForCollectionView:noteView];
            [self.collectionView addSubview:noteView];
        }
    
        CGPoint newCenter = CGPointMake(positionX, positionY);
        if (noteStackingId && noteView.superview == self.collectionView)
        {
            [noteView removeFromSuperview];
            [CollectionLayoutHelper moveView:noteView inCollectionView:self.collectionView toNewCenter:newCenter
                              withCompletion:^{
                [noteView removeFromSuperview];
            }];
        }
        
        //scale = scale / view.scaleOffset;
        //This very bad design. stacking position is dependant on note position
        //but stacking scale is not.
        //TODO Make the position of the stacking be independent
        if ([view isKindOfClass:[NoteView class]] && scale != 0 && view.scaleOffset != scale)
        {
            [view scaleWithScaleOffset:scale animated:scale];
        }
        
        CGPoint oldCenter = view.center;
        if (!CGPointEqualToPoint(newCenter, oldCenter))
        {
            [CollectionLayoutHelper moveView:view
                            inCollectionView:self.collectionView
                                  toNewCenter:newCenter];
        }
    }
}

-(void) noteDeletedEventOccured:(NSNotification *) notification
{
    NSDictionary * userInfo = notification.userInfo;
    NSDictionary * result = userInfo[@"result"];
    for(NSString * noteId in result)
    {
        NSLog(@"CollectionViewController: Note Delete Event Received for %@", noteId);
        NoteView * noteView = [self getNoteView:noteId];
        if (noteView == nil) break;
        
        //if noteView belongs to a stack we should remove it from the stack
        NSString * noteStackingId = result[noteId][@"stacking"];
        if ( noteStackingId != nil)
        {
            NSLog(@"CollectionViewController: Note%@ is part of stacking %@; deleting it from stacking", noteId, noteStackingId);
            StackView * stackView = self.stackViews[noteStackingId];
            [stackView removeNoteView:noteView];
            [noteView removeFromSuperview];
            [self updatePresentingStackViewControllerIfNecessaryForStackView:stackView];
        }
        else
        {
            [CollectionAnimationHelper animateDeleteView:noteView
                                      fromCollectionView:self.collectionView
                                 withCallbackAfterFinish:^(void){
                                     [noteView removeFromSuperview];
                                 }];
        }
        
        self.noteCount--;
        [self.noteViews removeObjectForKey:noteId];
        [self.imageNoteViews removeObjectForKey:noteId];
    }
}

-(NSArray *) getAllNoteViewsForStacking:(CollectionStackingAttribute *) stacking
{
    //get All the NoteViews
    NSMutableArray * stackNotes = [NSMutableArray array];
    for(NSString * noteRefId in stacking.refIds)
    {
        if (self.noteViews[noteRefId])
        {
            [stackNotes addObject:self.noteViews[noteRefId]];
        }
        else if (self.imageNoteViews[noteRefId])
        {
            [stackNotes addObject:self.imageNoteViews[noteRefId]];
        }
    }
    return stackNotes;
}

-(void) stackAddedEventOccured:(NSNotification *) notification
{
    NSArray * result = notification.userInfo[@"result"];
    for (NSString * stackId in result)
    {
        NSLog(@"CollectionViewController: Stacking Added Event Received for %@", stackId);
        CollectionStackingAttribute * stacking = [self.board getStackModelFor:stackId];
        if (stacking)
        {
            NSArray * stackNotes = [self getAllNoteViewsForStacking:stacking];
            
            //select the last note as the mainView candidate for now; will overRide later
            NoteView * mainView = [stackNotes lastObject];
            CGRect stackFrame = [CollectionLayoutHelper getStackingFrameForStackingWithTopView:mainView];
            StackView * stack = [[StackView alloc] initWithViews:[stackNotes mutableCopy]
                                                     andMainView:mainView
                                                       withFrame:stackFrame];
            //scale the stack if necessary
            float scaling = [stacking.scale floatValue];
            scaling = scaling/stack.scaleOffset;
            if (scaling && stack.scaleOffset != scaling) [stack scale:scaling animated:YES];
            
            //add stacking
            stack.ID = stackId;
            StackView * stackRef = stack;
            self.stackViews[stackId] = stackRef;
            [self addGestureRecognizersToStack:stack];
            [CollectionAnimationHelper animateStackCreationForStackView:stack WithMainView:mainView inCollectionView:self.collectionView];
        }
    }
}

-(void) addNewNotesWith:(NSSet *) newRefIds toStacking:(StackView *) stack
{
    for(NSString * noteId in newRefIds)
    {
        NoteView * noteView = self.noteViews[noteId];
        //if they are not part of the stack already
        if (noteView.superview == self.collectionView)
        {
            CGPoint newCenter = stack.center;
            if (noteView)
            {
                if ( noteView.center.x != stack.center.x ||
                    noteView.center.y != stack.center.y)
                {
                    [CollectionLayoutHelper moveView:noteView
                                    inCollectionView:self.collectionView
                                          toNewCenter:newCenter
                                       withCompletion:^{
                        [stack addNoteView:noteView];
                    }];
                }
                else
                {
                    [stack addNoteView:noteView];
                }
                
            }
        }
    }
}

-(void) removeNotesWith:(NSSet *) oldRefIds
           fromStacking:(StackView *) stack
{
    for(NSString * noteId in oldRefIds)
    {
        NoteView * noteView = self.noteViews[noteId];
        //if the note is not already deattached from the stack view
        if (noteView.superview != self.collectionView)
        {
            [self removeNoteView:noteView fromStackView:stack updateNote:YES];
        }
    }
}

-(void) removeNoteView:(NoteView *) noteView
         fromStackView:(StackView *)stack
            updateNote:(BOOL) update
{
    [stack removeNoteView:noteView];
    
    [self sanitizeNoteViewForCollectionView:noteView];
    
    //
    if (!update) return;
    
    [CollectionLayoutHelper removeNote:noteView
                             fromStack:stack
                      InCollectionView:self.collectionView
                      withCountInStack:[stack.views count]
                           andCallback:^(void){
                               float noteXCenter = noteView.center.x;
                               float noteYCenter = noteView.center.y;
                               [CollectionLayoutHelper adjustNotePositionsForX:&noteXCenter
                                                                          andY:&noteYCenter
                                                                        inView:self.collectionView];
                               noteView.center = CGPointMake(noteXCenter,
                                                             noteYCenter);
                               if (update)
                               {
                                   [self updateScalingAndPositionAccordingToNoteView:noteView];
                               }
                           }];
}

-(void) sanitizeNoteViewForCollectionView:(NoteView *) view
{
    for (UIGestureRecognizer * gr in view.gestureRecognizers){
        [view removeGestureRecognizer:gr];
    }
    
    [self addGestureRecognizersToNote:view];
    
    [view resetSize];
    view.delegate = self;
    
}

-(void) stackUpdatedEventOccured:(NSNotification *) notification
{
    
    NSArray * result = notification.userInfo[@"result"];
    for (NSString * stackId in result)
    {
        NSLog(@"CollectionViewController: Stacking update Event Received for %@", stackId);
        CollectionStackingAttribute * stacking = [self.board getStackModelFor:stackId];
        
        if (stacking == nil) break;
    
        StackView * stack = self.stackViews[stackId];
        float scaling = [stacking.scale floatValue];
        
        //scaling = scaling / stack.scaleOffset;
        if (scaling && stack.scaleOffset != scaling)
        {
            [stack scaleWithScaleOffset:scaling animated:YES];
        }
        
        NSMutableSet * newRefIds = [stacking.refIds mutableCopy];
        NSMutableSet * oldRefIds = [stack.getAllNoteIds mutableCopy];
        //notes that are newly added to the stack
        [newRefIds minusSet:oldRefIds];
        NSLog(@"CollectionViewController: adding notes %@ to stacking", newRefIds);
        [self addNewNotesWith:newRefIds toStacking:stack];
        
        //notes that are deleted and should no longer be in the stack
        [oldRefIds minusSet:stacking.refIds];
        NSLog(@"CollectionViewController: removing notes %@ from stacking", oldRefIds);
        [self removeNotesWith:oldRefIds fromStacking:stack];
        
        [self updatePresentingStackViewControllerIfNecessaryForStackView:stack];
    }
}


-(void) stackDeletedEventOccured:(NSNotification *) notification
{
    
    NSArray * result = notification.userInfo[@"result"];
    for(NSString * stackId in result)
    {
        NSLog(@"CollectionViewController: Stacking Delete Event Received for %@", stackId);
        StackView * stack = self.stackViews[stackId];
        [self.stackViews removeObjectForKey:stackId];
        
        if ([self.presentedViewController isKindOfClass:[StackViewController class]])
        {
            StackViewController * openStackController = (StackViewController *) self.presentedViewController;
            if (openStackController.openStack == stack)
            {
                [self dismissViewControllerAnimated:YES completion:^{}];
            }
        }
        
        if (stack == nil) break;
        
        NSArray * enumeratableArray = [stack.views copy];
        for(NoteView * note in enumeratableArray)
        {
            if (note.superview != self.collectionView)
            {
                [self removeNoteView:note
                       fromStackView:stack
                          updateNote:NO];
                [note removeFromSuperview];
            }
        }
        
        [CollectionAnimationHelper animateDeleteView:stack fromCollectionView:self.collectionView withCallbackAfterFinish:^(void)
         {
             [stack removeFromSuperview];
         }];
    }
}

-(void) noteContentUpdateEventOccured:(NSNotification *) notification
{
    NSLog(@"CollectionViewController- Note Content Updated");
    NSDictionary * userInfo = notification.userInfo;
    NSArray * result = userInfo[@"result"];
    for(NSString * noteId in result)
    {
        CollectionNote * noteObj = [self.board getNoteContent:noteId];
        
        if (noteObj == nil) break;
        
        NoteView * noteView = [self getNoteView:noteId];
        if (noteView == nil) break;
        
        noteView.text = noteObj.noteText;
        NSString * noteStackingId = [self.board stackingForNote:noteId];
        if (noteStackingId != nil)
        {
            StackView * stackView = self.stackViews[noteStackingId];
            [stackView setTopViewForNote:noteView];
        }
    }
}

-(void) noteImageUpdateEventOccured:(NSNotification *) notification
{
    NSDictionary * userInfo = notification.userInfo;
    NSArray * result = userInfo[@"result"];
    for(NSString * noteId in result)
    {
        CollectionNote * noteObj = [self.board getNoteContent:noteId];
        if (noteObj == nil) break;
        
        ImageNoteView * imageView = self.imageNoteViews[noteId];
        if (imageView == nil) break;
        
        NSData * imgData = [self.board getImageForNote:noteId];
        imageView.image = [UIImage imageWithData:imgData];
    }
}

#pragma mark - UI helpers

-(void) clearView
{
    for(UIView * view in self.collectionView.subviews){
        [view removeFromSuperview];
    }
}

-(void) layoutStackView: (StackView *) stack inRect: (CGRect) rect{
    
    NSArray * items = stack.views;
    [self removeNotesFromStackView:stack];
    [CollectionAnimationHelper animateStackViewRemoval:stack];
    [CollectionLayoutHelper expandNotes:items inRect:rect withMoveNoteFunction:^(NoteView * noteView){
        [self updateNoteLocation:noteView];
    }];
}

-(NoteView * ) addNote:(NSString *) noteID
   toViewWithNoteModel:(CollectionNoteAttribute *) noteModel
        andNoteContent:(CollectionNote *) noteContent
{
    
    float positionX = [noteModel.positionX floatValue];
    float positionY = [noteModel.positionY floatValue];
    float scale = [noteModel.scaling floatValue];
    
    [CollectionLayoutHelper adjustNotePositionsForX:&positionX
                                               andY:&positionY
                                             inView: self.collectionView];
    
    NoteView * note = [self getNoteViewForNote:noteID
                                          ForX:positionX
                                          andY:positionY
                                      andScale:scale];
    self.noteViews[noteID] = note;
    if (noteContent.noteText) note.text = noteContent.noteText;
    note.ID = noteID;
    note.delegate = self;
    
    [CollectionAnimationHelper animateNoteAddition:note
                                  toCollectionView:self.collectionView];
    [self addGestureRecognizersToNote:note];
    return note;
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
                stackNoteView.center = stack.center;
                [self updateNoteLocation:stackNoteView];
            }
        }
        self.highlightedView = nil;
        
    }
    [self resignFirstResponders];
}

-(void) screenDoubleTapped:(UITapGestureRecognizer *) sender{
    
    if (self.editMode) return;
    
    CGPoint location = [sender locationOfTouch:0 inView:self.collectionView];
    CGRect frame = [CollectionLayoutHelper getFrameForNewNote:sender.view
                                                 AddedToPoint:location
                                             InCollectionView:self.collectionView];
    NoteView * note =  [self.prototypeNoteView prototype];
    //this is addition so view has no transform over it. So its okey to use frame
    note.frame = frame;
    NSString * noteID = [AttributeHelper generateUUID];
    note.ID = noteID;
    //use weak ref to avoid leakage
    NoteView * noteRef = note;
    self.noteViews[note.ID] = noteRef;
    note.delegate = self;
    
    [CollectionAnimationHelper animateNoteAddition:note
                                  toCollectionView:self.collectionView];
    
    [self.collectionView addSubview:note];
    [self addGestureRecognizersToNote:note];
    
    [self addNoteToModel:note withID:noteID];
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
            [self editModeFinishedForNoteView:sender.view];
        }
        else{
            [self editModeStartedForNoteView:sender.view];
        }
    }
}

-(void) editModeFinishedForNoteView:(UIView *) view
{
    
    self.editMode = NO;
    self.highlightedView = nil;
    [self removeContextualToolbarItems:view];
    
    if ([view conformsToProtocol:@protocol(BulletinBoardObject)]){
        ((UIView <BulletinBoardObject> * ) view).highlighted = NO;
    }
    
    if ([view isKindOfClass:[NoteView class]]){
        [self updateNoteLocation:(NoteView *) view];
    }
    else if ([view isKindOfClass:[StackView class]]){
        StackView * stack = (StackView *) view;
        for(NoteView * stackNoteView in stack.views){
            stackNoteView.center = stack.center;
            [self updateNoteLocation:stackNoteView];
        }
    }
}

-(void) editModeStartedForNoteView:(UIView *) view
{
    
    self.editMode = YES;
    self.highlightedView = (UIView <BulletinBoardObject> *) view;
    
    [self addContextualToolbarItems:view];
    
    if ([view conformsToProtocol:@protocol(BulletinBoardObject)]){
        ((UIView <BulletinBoardObject> * ) view).highlighted = YES;
    }
}

-(void) objectPanned: (UIPanGestureRecognizer *) sender{
    
    if( sender.state == UIGestureRecognizerStateChanged ||
       sender.state == UIGestureRecognizerStateEnded){
        CGPoint translation = [sender translationInView:self.collectionView];
        UIView * pannedView = [sender view];
        //use center because the view may be rotated and in that case as
        //apple documentation suggest the frame property is not to be
        //trusted
        CGPoint newCenter = CGPointMake(pannedView.center.x + translation.x,
                                        pannedView.center.y + translation.y);
        pannedView.center = newCenter;
        [sender setTranslation:CGPointZero inView:self.collectionView];
        
        if (self.editMode) return;
        
        //every time user pans self.pancounter we check for to intersecting views
        self.panCounter++;
        if (self.panCounter > CHECK_TIME ){
            [self updateIntersectingViewsWithView:sender.view];
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded){
        [self panFinishedForView:sender.view];
    }
}

-(void) updateIntersectingViewsWithView:(UIView *)view
{
    self.panCounter = 0;
    NSArray * intersectingViews = [CollectionLayoutHelper checkForOverlapWithView: view
                                                                 inCollectionView:self.collectionView];
    if ( [intersectingViews count] != [self.intersectingViews count] ||
        [intersectingViews count] == 1){
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

-(void) panFinishedForView:(UIView *)view
{
    [CollectionLayoutHelper updateViewLocationForView:view
                                     inCollectionView:self.collectionView];
    
    for (UIView * intersectingView in self.intersectingViews){
        intersectingView.alpha = 1;
    }
    
    if ([self.intersectingViews count] > 1 ){
        UIView * mainView = [self findMainViewForIntersectingViews: self.intersectingViews
                                                     withCandidate:view];
        float scale = 1;
        [self createStackingWithItems:self.intersectingViews
                          andMainView:mainView
                  withDestinationView:view withScale:scale];
    }
    
    if([view isKindOfClass:[NoteView class]]){
        [self updateNoteLocation:(NoteView *) view];
    }
    else if ([view isKindOfClass:[StackView class]]){
        StackView * stack = (StackView *) view;
        for(NoteView * stackNoteView in stack.views){
            //stackNoteView.center = stack.center;
            [self updateNoteLocation:stackNoteView];
        }
    }
}

-(void) stackTapped: (UIPanGestureRecognizer *) sender{
    StackViewController * stackViewer = [self.storyboard instantiateViewControllerWithIdentifier:@"StackView"];
    stackViewer.delegate = self;
    stackViewer.openStack = (StackView *) sender.view;
    [self presentViewController:stackViewer animated:YES completion:^{}];
}

-(void) objectRotated:(UIRotationGestureRecognizer *) sender
{
    if (sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded)
    {
        CGFloat rotation = sender.rotation;
        
        if ([sender.view conformsToProtocol:@protocol(BulletinBoardObject)])
        {
            UIView <BulletinBoardObject> * view = (NoteView *) sender.view;
            [view rotate:rotation];
        }
        
        if (sender.state == UIGestureRecognizerStateEnded)
        {
            //update model
        }
        
        sender.rotation = 0;
    }
}

-(void) objectPinched: (UIPinchGestureRecognizer *) sender{
    
    if (sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded){
        CGFloat scale = sender.scale;
        if ([sender.view conformsToProtocol: @protocol(BulletinBoardObject)]){
            UIView <BulletinBoardObject> * view = (NoteView *) sender.view;
            
            //if the view is highlighted we don't want to scale
            if (view.highlighted) return;
            
            [view scale:scale animated:NO];
            if (sender.state == UIGestureRecognizerStateEnded)
            {
                CGFloat scaleOffset = view.scaleOffset;
                NSString * mainViewId = view.ID;
                if ([view isKindOfClass:[StackView class]])
                {
                    
                    [self updateScaleForStack:mainViewId withScale:scaleOffset];
                }
                else
                {
                    [self updateScaleForNote: mainViewId withScale:scaleOffset];
                }
            }
        }
        sender.scale = 1 ;
    }
}

#pragma mark - UI Events

-(void) viewWillAppear:(BOOL)animated{
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    UILabel * titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    titleView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    titleView.backgroundColor = [UIColor clearColor];
    titleView.textColor = [UIColor whiteColor];
    titleView.text = self.bulletinBoardName;
    self.navigationItem.titleView = titleView;
    [titleView sizeToFit];
}

-(void) initateDataStructures
{
    self.imageNoteViews = [NSMutableDictionary dictionary];
    self.noteViews = [NSMutableDictionary dictionary];
    self.stackViews = [NSMutableDictionary dictionary];
}

-(void) removePrototypesFromView
{
    [self.prototypeNoteView removeFromSuperview];
    [self.prototypeImageView removeFromSuperview];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self removePrototypesFromView];
    self.shouldRefresh = YES;
    [self configureToolbar];
    
    
    self.navigationItem.rightBarButtonItems = [self.toolbar.items copy];
    [self initateDataStructures];
    
    CGSize size =  CGSizeMake(self.collectionView.bounds.size.width,
                              self.collectionView.bounds.size.height);
    [self.collectionView setContentSize:size];
    
    [self addCollectionViewGestureRecognizersToCollectionView: self.collectionView];
    
    [self addInitialObservers];
    [self addListenerNotifications];
    self.collectionView.delegate = self;
}

-(void) addInitialObservers
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSavedNotes:)
                                                 name:COLLECTION_RELOAD_EVENT
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noteImageReady:)
                                                 name:ASSOCIATION_IMAGE_READY_EVENT
                                               object:self.board];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ApplicationHasGoneInBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAppeared:)
                                                 name:UIKeyboardDidShowNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDisappeared:)
                                                 name:UIKeyboardDidHideNotification
                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}
//maybe in view will appear
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.shouldRefresh)
    {
        [self layoutNotes];
        self.shouldRefresh = NO;
    }
}

-(void) configureToolbar
{
    NSMutableArray * toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObject:self.deleteButton];
    [toolbarItems removeObject:self.expandButton];
    self.toolbar.items = toolbarItems;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [CollectionLayoutHelper layoutViewsForOrientationChange:self.collectionView];
}

-(void) viewDidUnload
{
    [self setTitle:nil];
    [self setView:nil];
    [self setCollectionView:nil];
    [self setToolbar:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (IBAction)cameraPressed:(id)sender {
    
    if (self.lastPopOver) return;
    
    UIActionSheet * action = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"Camera", @"Library", nil];
    //make sure an actionsheet is not presented on top of another not dismissed one
    if (self.activeImageSheet)
    {
        [self.activeImageSheet dismissWithClickedButtonIndex:-1 animated:NO];
        self.activeImageSheet = nil;
    }
    [action showFromBarButtonItem:sender animated:NO];
    self.activeImageSheet = action;
}


-(IBAction) expandPressed:(id) sender {
    
    if ([self.highlightedView isKindOfClass:[StackView class]] && self.editMode)
    {
        CGRect fittingRect = [CollectionLayoutHelper findFittingRectangle: (StackView *) self.highlightedView
                                                                   inView:self.collectionView];
        
        //move stuff that is in the rectangle out of it
        [CollectionLayoutHelper clearRectangle: fittingRect
                              inCollectionView:self.collectionView
                          withMoveNoteFunction:^(NoteView * note){
                              [note resetSize];
                              [self updateScalingAndPositionAccordingToNoteView:note];
                          }];
        
        //layout stack in the empty rect
        [self layoutStackView:(StackView *) self.highlightedView inRect:fittingRect ];
        
        //clean up
        [self removeContextualToolbarItems:self.highlightedView];
        NSString * stackingID = ((StackView *)self.highlightedView).ID;
        [self.board removeStacking:stackingID];
        [self.stackViews removeObjectForKey:stackingID];
        
        self.highlightedView = nil;
        self.editMode = NO;
    }
}

-(IBAction) deletePressed:(id) sender {
    
    if(!self.editMode) return;
    
    [self removeContextualToolbarItems:self.highlightedView];
    
    if ([self.highlightedView isKindOfClass:[StackView class]]){
        [self deleteStack:(StackView *) self.highlightedView];
    }
    else if ([self.highlightedView isKindOfClass:[NoteView class]]){
        
        [self deleteNote:(NoteView *) self.highlightedView];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.activeImageSheet dismissWithClickedButtonIndex:-1 animated:NO];
    
    [self.lastPopOver dismissPopoverAnimated:YES];
    NSData * thumbnailData = [self saveCollectionThumbnail];
    [self.board save];
    [self.board cleanUp];
    [self.parent finishedWorkingWithCollection:self.bulletinBoardName withThumbnailData:thumbnailData];
    
}

- (IBAction)refreshPressed:(id)sender {
    
    NSLog(@"Notes ----- \n %@", self.noteViews);
    NSLog(@"Stacks ---- \n %@", self.stackViews);
}

-(void) addRefreshObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSavedNotes:)
                                                 name:COLLECTION_RELOAD_EVENT
                                               object:self.board];
}
#pragma mark - layout methods

-(void) layoutNotes{
    
    NSDictionary * allNotes = [self.board getAllNotesContents];
    self.noteCount = [allNotes count];
    for(NSString* noteID in allNotes){
        CollectionNote * noteObj = allNotes[noteID];
        CollectionNoteAttribute * noteModel = [self.board getNoteModelFor:noteID];
        
        [self addNote:noteID
  toViewWithNoteModel:noteModel
       andNoteContent:noteObj];
    }
    
    [self layoutStackings];
}


-(void) layoutStackings{
    NSDictionary * stackings =[self.board getAllStackings];
    
    //Find out which notes belong to the stacking and put them there
    for(NSString * stackingID in stackings){
        NSMutableArray * views = [[NSMutableArray alloc] init];
        CollectionStackingAttribute * stackingModel = stackings[stackingID];
        NSArray * noteRefIds = [stackingModel.refIds allObjects];
        UIView * mainView = [self storeNotesViewsForNotes:noteRefIds into:views];
        CGFloat scale = [stackingModel.scale floatValue];
        [self stackNotes:views
                    into:mainView
     withDestinationView:mainView
                  withID:stackingID
               withScale:scale];
    }
}

#pragma mark - Note Actions

-(NSString *) addNoteToModel: (NoteView *) note
                      withID:(NSString *) noteID
{
    
    note.ID = noteID;
    CollectionNoteAttribute * noteCollectionAttribute = [self createXoomlNoteModel:note];
    NSString * noteName = noteCollectionAttribute.noteName;
    CollectionNote * noteItem = [[CollectionNote alloc] initEmptyNoteWithID:noteID andName:noteName];
    noteItem.noteText = note.text;
    
    [self.board addNoteWithContent:noteItem
                      andCollectionAttributes:noteCollectionAttribute];
    
    return noteID;
}

-(NSString *) addImageNoteToModel: (ImageNoteView *) note withId:(NSString *) noteID
{
    
    CollectionNoteAttribute * noteModel = [self createXoomlNoteModel:note];
    NSString * noteName = noteModel.noteName;
    CollectionNote * noteItem = [[CollectionNote alloc] initEmptyNoteWithID:noteID andName:noteName];
    noteItem.noteText = note.text;
    note.ID = noteID;
    [noteItem setImageAsDefaultFragmentImage];
    
    NSData * imgData = UIImageJPEGRepresentation(note.image, IMG_COMPRESSION_QUALITY);
    noteItem.name = noteModel.noteName;
    
    [self.board addImageNoteContent:noteItem
                           andModel:noteModel
                           andImage:imgData
                            forNote:noteID];
    return noteID;
}

-(CollectionNoteAttribute *) createXoomlNoteModel: (NoteView *) note
{
    
    if (self.noteCount < 0 ) self.noteCount = 1;
    
    NSString * noteName = [NSString stringWithFormat:@"Note%d",self.noteCount];
    self.noteCount++;
    
    noteName = [NamingHelper getBestNameFor:noteName
                              amongAllNAmes:[self.board getAllNoteNames]];
    NSString * positionX = [NSString stringWithFormat:@"%f", note.center.x];
    NSString * positionY = [NSString stringWithFormat:@"%f", note.center.y];
    NSString * scale = [NSString stringWithFormat:@"%f", note.scaleOffset];
    NSString * noteId = note.ID;
    
    return [[CollectionNoteAttribute alloc] initWithName:noteName
                                                andRefId:noteId
                                   andPositionX:positionX
                                   andPositionY:positionY
                                     andScaling:scale];
    
}

-(void) updateNoteLocation:(NoteView *) view
                toMainView:(UIView *) mainView
{
    NSString * noteID = view.ID;
    float positionFloatX = mainView.center.x;
    NSString * positionX = [NSString stringWithFormat:@"%f",positionFloatX];
    float positionFloatY = mainView.center.y;
    NSString * positionY = [NSString stringWithFormat:@"%f",positionFloatY];
    
    CollectionNoteAttribute * oldModel = [self.board getNoteModelFor:view.ID];
    oldModel.positionX = positionX;
    oldModel.positionY = positionY;
    [self.board updateNoteAttributes:noteID withModel:oldModel];
}
-(void) updateNoteLocation:(NoteView *) view
{
    NSString * noteID = view.ID;
    float positionFloat = view.center.x;
    NSString * positionX = [NSString stringWithFormat:@"%f",positionFloat];
    positionFloat = view.center.y;
    NSString * positionY = [NSString stringWithFormat:@"%f",positionFloat];
    
    CollectionNoteAttribute * oldModel = [self.board getNoteModelFor:view.ID];
    oldModel.positionX = positionX;
    oldModel.positionY = positionY;
    [self.board updateNoteAttributes:noteID withModel:oldModel];
}

-(void) updateScaleForNote:(NSString *) noteId withScale:(CGFloat) scaleOffset
{
    NSString * scale = [NSString stringWithFormat:@"%f", scaleOffset];
    CollectionNoteAttribute * oldModel = [self.board getNoteModelFor:noteId];
    oldModel.scaling = scale;
    [self.board updateNoteAttributes:noteId withModel:oldModel];
}

-(void) updateScalingAndPositionAccordingToNoteView:(NoteView *) view
{
    
    NSString * noteID = view.ID;
    float positionFloat = view.center.x;
    NSString * positionX = [NSString stringWithFormat:@"%f",positionFloat];
    positionFloat = view.center.y;
    NSString * positionY = [NSString stringWithFormat:@"%f",positionFloat];
    NSString * scale = [NSString stringWithFormat:@"%f", view.scaleOffset];
    
    CollectionNoteAttribute * oldModel = [self.board getNoteModelFor:view.ID];
    oldModel.positionX = positionX;
    oldModel.positionY = positionY;
    oldModel.scaling = scale;
    [self.board updateNoteAttributes:noteID withModel:oldModel];
}
-(void) updateScaleForStack:(NSString *) stackID withScale:(CGFloat) scaleOffset
{
    
    NSString * scale = [NSString stringWithFormat:@"%f", scaleOffset];
    CollectionStackingAttribute * oldModel = [self.board getStackModelFor:stackID];
    oldModel.scale = scale;
    [self.board updateStacking:stackID withNewModel:oldModel];
}

/*
 As a side effect removes any note in a stackView
 */
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

-(NoteView *) getNoteViewForNote: (NSString *) noteID
                            ForX:(float) positionX
                            andY:(float) positionY
                        andScale:(float) scale
{
    
    BOOL isImageNote = [self.board doesNoteHaveImage:noteID];
    CGRect noteFrame = CGRectMake(positionX - NOTE_WIDTH/2,
                                  positionY - NOTE_HEIGHT/2,
                                  NOTE_WIDTH,
                                  NOTE_HEIGHT);
    if (isImageNote)
    {
        ImageNoteView * note;
        NSData * imgData = [self.board getImageForNote:noteID];
        UIImage * img = [[UIImage alloc] initWithData:imgData];
        note = [self.prototypeImageView prototype];
        //since the note has not have a transform set at this point
        //its okey to set it frame instead of center
        note.frame = noteFrame;
        note.image = img;
        note.ID = noteID;
        NoteView * noteRef = note;
        self.imageNoteViews[note.ID] = noteRef;
        self.noteViews[note.ID] = noteRef;
        [note scale:scale animated:NO];
        return note;
    }
    else
    {
        NoteView * note ;
        note =  [self.prototypeNoteView prototype];
        note.frame = noteFrame;
        note.ID = noteID;
        NoteView * noteRef = note;
        self.noteViews[note.ID] = noteRef;
        [note scale:scale animated:NO];
        return note;
    }
}

-(UIView *) storeNotesViewsForNotes:(NSArray *) noteRefIDs
                               into:(NSMutableArray *) views
{
    NSSet * noteRefs = [[NSSet alloc] initWithArray:noteRefIDs];
    UIView * mainViewCandidate;
    for (UIView * view in self.collectionView.subviews){
        if ([view isKindOfClass:[NoteView class]]){
            NSString * noteID = ((NoteView *) view).ID;
            if ([noteRefs containsObject:noteID]){
                [views addObject:view];
                //make sure that the latest note added will be shown on the top of the stacking
                if ([noteID isEqualToString:noteRefIDs[0]]){
                    mainViewCandidate = view;
                }
            }
        }
    }
    //find the best mainView
    UIView * mainView = [self findMainViewForIntersectingViews:views
                                                 withCandidate:mainViewCandidate];
    return mainView;
}

-(void) deleteNote:(NoteView *) note
{
    [self.board removeNoteWithID:(note.ID)];
    self.noteCount--;
    
    [CollectionAnimationHelper animateDeleteView:note fromCollectionView:self.collectionView withCallbackAfterFinish:^(void){
        [note removeFromSuperview];
        self.editMode = NO;
        self.highlightedView = nil;
    }];
    
    [self.noteViews removeObjectForKey:note.ID];
    [self.imageNoteViews removeObjectForKey:note.ID];
}

#pragma mark - Stack Actions

-(UIView *) findMainViewForIntersectingViews:(NSArray *) views withCandidate:(UIView *) candidate
{
    //if the candidate is an image view or is a stack with an image view on top
    //the candidate is the mainView
    if ([candidate isKindOfClass:[ImageNoteView class]]) return candidate;
    if ([candidate isKindOfClass:[StackView class]])
    {
        UIView * topOfStack = ((StackView *) candidate).mainView;
        if ([topOfStack isKindOfClass:[ImageNoteView class]])
        {
            return topOfStack;
        }
    }
    else
    {
        UIView * mainView = nil;
        UIView * mainViewCandidate = nil;
        //if there is any image view in the intersecting items then thats the mainView
        for (UIView * view in views)
        {
            if ([view isKindOfClass:[ImageNoteView class]])
            {
                mainView = view;
                return mainView;
            }
            //if not then any stackView that has top item which is imageview could be the top of stack
            else if ([view isKindOfClass:[StackView class]])
            {
                UIView * topOfStack = ((StackView *) view).mainView;
                if ([topOfStack isKindOfClass:[ImageNoteView class]])
                {
                    mainViewCandidate = topOfStack;
                }
            }
        }
        //if we found a better candidate return that, otherwise the first candidate is the mainview
        if (mainViewCandidate != nil)
        {
            return mainViewCandidate;
        }
        else
        {
            return candidate;
        }
    }
    return candidate;
}

/*! creates an stacking with all the notes in the items.
    P
 */
-(NSString *) createStackingWithItems:(NSArray *) items
                    andMainView:(UIView *) mainView
            withDestinationView:(UIView *) destinationView
                      withScale:(CGFloat) scale
{
    
    NSMutableArray * allNotes = [self getAllNormalNotesInViews:items];
    
    CGRect stackFrame = [CollectionLayoutHelper getStackingFrameForStackingWithTopView:destinationView];
    
    if ([mainView isKindOfClass:[StackView class]])
    {
        mainView = ((StackView *)mainView).mainView;
    }
    
    NSString * stackingID = [self mergeItems: items
                      intoStackingWithMainView: mainView];
    
    
    
    StackView * stack = [[StackView alloc] initWithViews:allNotes
                                             andMainView:(NoteView *)mainView
                                               withFrame:stackFrame];
    stack.ID = stackingID;
    StackView * stackRef = stack;
    self.stackViews[stackingID] = stackRef;
    
//    if (scale)
//    {
//        [stack scale:scale animated:NO];
//    }
    stack.ID = stackingID;
    
    [self addGestureRecognizersToStack:stack];
    [self.collectionView addSubview:stack];
    
//    [CollectionAnimationHelper animateStackCreationForStackView:stack
//                                            WithDestinationView:destinationView
//                                                  andStackItems:allNotes
//                                               inCollectionView:self.collectionView
//                                                          isNew:YES
//                                           withMoveNoteFunction:^(NoteView * note){
//                                               [self updateNoteLocation:note toMainView:mainView];
//                                           }];
    
    
    return stackingID;
}

-(void) stackNotes: (NSArray *) items
              into: (UIView *) mainView
withDestinationView:(UIView *) destinationView
            withID: (NSString *) ID
         withScale:(CGFloat) scale
{
    NSMutableArray * allNotes = [self getAllNormalNotesInViews:items];
    
    CGRect stackFrame = [CollectionLayoutHelper getStackingFrameForStackingWithTopView:destinationView];
    
    if ([mainView isKindOfClass:[StackView class]])
    {
        mainView = ((StackView *)mainView).mainView;
    }
    
    NSString * stackingID = ID;
    
    StackView * stack = [[StackView alloc] initWithViews:allNotes
                                             andMainView:(NoteView *)mainView
                                               withFrame:stackFrame];
    stack.ID = stackingID;
    StackView * stackRef = stack;
    self.stackViews[stackingID] = stackRef;
    
    if (scale)
    {
        [stack scale:scale animated:NO];
    }
    stack.ID = stackingID;
    
    [self addGestureRecognizersToStack:stack];
    [CollectionAnimationHelper animateStackCreationForStackView:stack
                                            WithDestinationView:destinationView
                                                  andStackItems:allNotes
                                               inCollectionView:self.collectionView
                                                          isNew:NO
                                           withMoveNoteFunction:^(NoteView * note){
                                               [self updateNoteLocation:note toMainView:mainView];
                                           }];
}

-(NSString *) mergeItems: (NSArray *)items
intoStackingWithMainView: (UIView *) mainView
{
    NSString * stackingID = nil;
    
    //first we need to find the designated stackingId
    //we check the main view first
    if ([mainView isKindOfClass:[StackView class]])
    {
        stackingID = ((StackView *) mainView).ID;
    }
    
    
    NSMutableArray * stackingNoteIDs = [NSMutableArray array];
    for(UIView * view in items)
    {
        if ([view isKindOfClass:[NoteView class]])
        {
            
            [stackingNoteIDs addObject:((NoteView *) view).ID];
        }
        else if ([view isKindOfClass:[StackView class]])
        {
            NSString * oldStackingID = ((StackView *)view).ID;
            //if we haven't found the designated stackingId yet
            //take this view as the stacking to be update and update that
            if (stackingID == nil)
            {
                stackingID = oldStackingID;
            }
            else
            {
                [self.board removeStacking:oldStackingID];
                [self.stackViews removeObjectForKey:oldStackingID];
                for (UIView * note in ((StackView *)view).views)
                {
                    NSString *stackingNoteID = ((NoteView *)note).ID;
                                [stackingNoteIDs addObject:stackingNoteID];
                }
            }
        }
    }
    
    NSString * topItemID;
    if ([mainView isKindOfClass:[NoteView class]]){
        topItemID = ((NoteView *) mainView).ID;
    }
    else if ([mainView isKindOfClass:[StackView class]]){
        topItemID = ((StackView *)mainView).mainView.ID;
    }
    
//    if (topItemID == nil) return stackingID;
    //make sure that the top of the stack is at index 0
    if ([stackingNoteIDs containsObject:topItemID])
    {
        if (topItemID != nil)
        {
            [stackingNoteIDs removeObject:topItemID];
            [stackingNoteIDs insertObject:topItemID atIndex:0];
        }
    }
    
    if (stackingID == nil)
    {
        stackingID = [AttributeHelper generateUUID];
    }
    
    [self.board addNotesWithIDs:stackingNoteIDs
                     toStacking:stackingID];
    
    return stackingID;
}

-(void) removeNotesFromStackView: (StackView *) stack
{
    
    NSArray * items = stack.views;
    [self.board removeStacking:stack.ID];
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
        view.center = stack.center;
        view.bounds = CGRectMake(view.bounds.origin.x,
                                 view.bounds.origin.y,
                                 stack.bounds.size.width,
                                 stack.bounds.size.height);
    }
}

-(void) deleteStack:(StackView *) stack
{
    [self.board removeStacking:stack.ID];
    
    for (NoteView * view in stack.views){
        self.noteCount--;
        [self.noteViews removeObjectForKey:view.ID];
        [view removeFromSuperview];
        [self.board removeNoteWithID:((NoteView *)view).ID];
    }
    
    [CollectionAnimationHelper animateDeleteView:stack fromCollectionView:self.collectionView withCallbackAfterFinish:^(void){
        [stack removeFromSuperview];
        self.editMode = NO;
        self.highlightedView = nil;
    }];
    [self.stackViews removeObjectForKey:stack.ID];
}

#pragma mark - Collection Actions
-(NSData *) saveCollectionThumbnail
{
    //If we take a new picture, we use that as thumbnail data
    //If we already had a picture in the collection and we didn't take a new one
    //we don't save any thumbnail data
    //otherwise we capture a screenshot of the screen
    NSData * thumbnailData = nil;
    if ([self.board isUpdateThumbnailNeccessary])
    {
        
        thumbnailData = [self.board getLastThumbnailImage];
        if (thumbnailData == nil)
        {
            thumbnailData = [MultimediaHelper captureScreenshotOfView:self.collectionView.superview];
        }
        [self.board saveThumbnail:thumbnailData];
    }
    return thumbnailData;
}

#pragma mark - Gesture recoginizers

-(void) addGestureRecognizersToNote:(NoteView *)note
{
    UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectPanned:)];
    UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(objectPinched:)];
    UILongPressGestureRecognizer * lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(objectPressed:)];
    UIRotationGestureRecognizer * rgr = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(objectRotated:)];
    
    [note addGestureRecognizer:lpgr];
    [note addGestureRecognizer:gr];
    [note addGestureRecognizer:rgr];
    [note addGestureRecognizer:pgr];
}

-(void) addGestureRecognizersToStack:(StackView *) stack
{
    UIPanGestureRecognizer * gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(objectPanned:)];
    UIPinchGestureRecognizer * pgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(objectPinched:)];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stackTapped:)];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(objectPressed:)];
    UIRotationGestureRecognizer * rgr = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(objectRotated:)];
    
    [stack addGestureRecognizer:gr];
    [stack addGestureRecognizer:pgr];
    [stack addGestureRecognizer:tgr];
    [stack addGestureRecognizer:lpgr];
    [stack addGestureRecognizer:rgr];
}

-(void) addCollectionViewGestureRecognizersToCollectionView: (UIView *) collectionView
{
    UITapGestureRecognizer * gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenDoubleTapped:)];
    gr.numberOfTapsRequired = 2;
    UITapGestureRecognizer * tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped:)];
    [collectionView addGestureRecognizer:gr];
    [collectionView addGestureRecognizer:tgr];
}

#pragma mark - Contextual Toolbar

-(void) removeContextualToolbarItems:(UIView *) contextView{
    
    NSMutableArray * newToolbarItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    [newToolbarItems removeObject:self.deleteButton];
    if( [contextView isKindOfClass:[StackView class]])
    {
        [newToolbarItems removeObject:self.expandButton];
    }
    self.navigationItem.rightBarButtonItems = newToolbarItems;
}

-(void) addContextualToolbarItems: (UIView *) contextView
{
    NSMutableArray * newToolbarItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    if ( [contextView isKindOfClass:[StackView class]]){
        [newToolbarItems addObject:self.expandButton];
    }
    [newToolbarItems addObject:self.deleteButton];
    self.navigationItem.rightBarButtonItems = newToolbarItems;
}

#pragma mark - stack delegate methods
-(void) returnedstackViewController:(StackViewController *)sender{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

-(void) unstackItem:(NoteView *) item
           fromView: (StackView *) stackView
      withPastCount: (int) count{
    
    if ( [item isKindOfClass:[NoteView class]]){
        NoteView * noteItem = (NoteView *) item;
        
        [stackView removeNoteView:noteItem];
        for (UIGestureRecognizer * gr in noteItem.gestureRecognizers){
            [noteItem removeGestureRecognizer:gr];
        }
        
        [self addGestureRecognizersToNote:noteItem];
        
        noteItem.delegate = self;
        [CollectionLayoutHelper removeNote:noteItem
                                 fromStack:(StackView *)stackView
                          InCollectionView:self.collectionView
                          withCountInStack:count
                               andCallback:^(void){
                                   NSString * stackName =((StackView*) stackView).ID;
                                   [self.board removeNote:noteItem.ID fromStacking:stackName];
                                   float noteXCenter = noteItem.center.x;
                                   float noteYCenter = noteItem.center.y;
                                   [CollectionLayoutHelper adjustNotePositionsForX:&noteXCenter
                                                                              andY:&noteYCenter
                                                                            inView:self.collectionView];
                                   noteItem.center = CGPointMake(noteXCenter, noteYCenter);
                                   [self updateScalingAndPositionAccordingToNoteView:noteItem];
                               }];
    }
}

-(void) stackViewDeletedNote:(NoteView *)note
{
    [self deleteNote:note];
}

-(void) stackViewIsEmpty:(StackView *)stackView
{
    [CollectionAnimationHelper animateDeleteView:stackView
                              fromCollectionView:self.collectionView
                         withCallbackAfterFinish:^(void){
                             [stackView removeFromSuperview];
                             self.editMode = NO;
                             self.highlightedView = nil;
                         }];
    [self.stackViews removeObjectForKey:stackView.ID];
    
    if ([self.presentedViewController isKindOfClass:[StackViewController class]])
    {
        //remove the stackView
        StackViewController * openStackController = (StackViewController *) self.presentedViewController;
        if (openStackController.openStack == stackView)
        {
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
    }
}

-(void) stack:(StackView *)stack IsEmptyForViewController:(StackViewController *)sender
{
    [self deleteStack:stack];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - note delegate
- (void) note: (id)note changedTextTo: (NSString *) text{
    
    NoteView * noteView = (NoteView *)note;
    NSString * noteId = noteView.ID;
    CollectionNote * newNoteObj = [[CollectionNote alloc] initWithText:text
                                                             andNoteId:noteId];
    [self.board updateNoteContentOf:noteId withContentsOf:newNoteObj];
}

-(void) resignFirstResponders{
    for(UIView * view in self.collectionView.subviews){
        if ([view conformsToProtocol:@protocol(BulletinBoardObject)]){
            id<BulletinBoardObject> obj = (id<BulletinBoardObject>) view;
            [obj resignSubViewsAsFirstResponder];
        }
    }
}

#pragma mark - action sheet delegate

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController * imagePicker = nil;
    if (buttonIndex == 0)
    {
        imagePicker= [MultimediaHelper getCameraController];
        if (imagePicker)
        {
            [self presentViewController:imagePicker animated:YES completion:^{}];
            imagePicker.delegate = self;
        }
    }
    else if (buttonIndex == 1)
    {
        imagePicker = [MultimediaHelper getLibraryController];
        imagePicker.delegate = self;
        UIPopoverController * presenter =
        [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        self.lastPopOver = presenter;
        self.lastPopOver.delegate = self;
        [presenter presentPopoverFromBarButtonItem:self.cameraButton
                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                          animated:YES];
    }
}

#pragma mark - image delegate
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
    [self.lastPopOver dismissPopoverAnimated:YES];
    self.lastPopOver = nil;
}


-(void) imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        [self dismissViewControllerAnimated:YES completion:^(void){}];
    }
    
    CGRect frame = CGRectMake(self.collectionView.bounds.origin.x + IMAGE_OFFSET_X,
                              self.collectionView.bounds.origin.y + IMAGE_OFFSET_Y,
                              NOTE_WIDTH,
                              NOTE_HEIGHT);
    
    //its okey to set frame cause there is not ransform on the item
    ImageNoteView * note = [self.prototypeImageView prototype];
    note.frame = frame;
    note.image = image;
    NSString * noteID = [AttributeHelper generateUUID];
    note.ID = noteID;
    note.delegate = self;
    
    ImageNoteView * imageViewRef = note;
    self.imageNoteViews[noteID] =imageViewRef;
    self.noteViews[noteID] = imageViewRef;
    
    [self addGestureRecognizersToNote:note];
    [CollectionAnimationHelper animateNoteAddition:note toCollectionView:self.collectionView];
    
    [self addImageNoteToModel:note withId:noteID];
    [self.lastPopOver dismissPopoverAnimated:YES];
    self.lastPopOver = nil;
}

#pragma mark - popover delegate
-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.lastPopOver = nil;
}

#pragma mark - keyboard notification
-(void) keyboardAppeared:(NSNotification *) notification
{
    //no need to figure out keyboard positioning if stack view is presented
    if (self.presentedViewController == nil)
    {
        NSDictionary * info = [notification userInfo];
        CGSize kbSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        float keyboardHeight = MIN(kbSize.height, kbSize.width);
        
        CGRect aRect = self.collectionView.bounds;
        
        if (self.activeView == nil) return;
        
        CGPoint noteViewCenter = self.activeView.center;
        //the -1 is there because we dont want the rightestCornerToNotFallInside 
        CGFloat noteViewRightestCorner = MIN(noteViewCenter.x + self.activeView.bounds.size.width/2,
                                             aRect.origin.x + aRect.size.width - 1);
        CGPoint noteViewRightcorner = CGPointMake(noteViewRightestCorner,
                                                  noteViewCenter.y + self.activeView.bounds.size.height/2);
        aRect.size.height -= keyboardHeight;
        if (!CGRectContainsPoint(aRect,noteViewRightcorner))
        {
            CGFloat spaceFromLowerCornerToBottom = self.collectionView.bounds.size.height - noteViewRightcorner.y;
            CGFloat addedVisibleSpaceY = keyboardHeight - spaceFromLowerCornerToBottom;
            CGPoint scrollPoint = CGPointMake(0.0, self.collectionView.bounds.origin.y + addedVisibleSpaceY);
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0);
            self.collectionView.contentInset = contentInsets;
            self.collectionView.scrollIndicatorInsets = contentInsets;
            [self.collectionView setContentOffset:scrollPoint animated:YES];
        }
    }
}

-(void) keyboardDisappeared:(NSNotification *) notification
{
    //no need to figure out keyboard positioning if stack view is presented
    if (self.presentedViewController == nil)
    {
        self.activeView = nil;
        CGPoint scrollPoint = CGPointMake(0.0, 0.0);
        [self.collectionView setContentOffset:scrollPoint animated:YES];
        //        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        //        self.collectionView.contentInset = contentInsets;
        //        self.collectionView.scrollIndicatorInsets = contentInsets;
    }
}

@end