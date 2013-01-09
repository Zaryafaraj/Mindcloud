//
//  DropBoxAssociativeBulletinBoard.m
//  IdeaStock
//
//  Created by Ali Fathalian on 4/6/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "DropBoxAssociativeBulletinBoard.h"
#import "DropboxDataModel.h"
#import "XoomlBulletinBoardController.h"
#import "DropboxDataModel.h"
#import "XoomlParser.h"
#import "FileSystemHelper.h"
#import "XoomlAttributeHelper.h"


#define ADD_BULLETIN_BOARD_ACTION @"addBulletinBoard"
#define UPDATE_BULLETIN_BOARD_ACTION @"updateBulletinBoard"
#define ADD_NOTE_ACTION @"addNote"
#define UPDATE_NOTE_ACTION @"updateNote"
#define ADD_IMAGE_NOTE_ACTION @"addImage"
#define ACTION_TYPE_CREATE_FOLDER @"createFolder"
#define ACTION_TYPE_UPLOAD_FILE @"uploadFile"


#define SYNCHRONIZATION_PERIOD 2
@interface DropBoxAssociativeBulletinBoard()

/*--------------------------------------------------
 
 Private Methods
 
 -------------------------------------------------*/

- (void) synchronize:(NSTimer *) timer;

/*--------------------------------------------------
 
 Synchronization Properties
 
 -------------------------------------------------*/

@property int fileCounter;
//this indicates that we need to synchronize
//any action that changes the bulletinBoard data model calls
//this and then nothing else is needed
@property BOOL needSynchronization;

@property NSTimer * timer;

/*--------------------------------------------------
 
 Dummy Properties
 
 -------------------------------------------------*/

@property NSString * demoBulletinBoardName;
@property NSString * demoNoteName;

@end

@implementation DropBoxAssociativeBulletinBoard

/*=======================================================*/

/*--------------------------------------------------
 
 Synthesis
 
 -------------------------------------------------*/

//TODO here I am patrially initializing the class. I think this is bad
@synthesize dataModel = _dataModel;
@synthesize fileCounter = _fileCounter;
@synthesize  needSynchronization =
_needSynchronization;
@synthesize  timer = _timer;
@synthesize demoNoteName = _demoNoteName;
@synthesize demoBulletinBoardName = _demoBulletinBoardName;
@synthesize actionInProgress = _actionInProgress;



- (DropboxDataModel *) dataModel{
    if (!_dataModel){
        _dataModel = [[DropboxDataModel alloc] init];
    }
    return (DropboxDataModel *)_dataModel;
}

/*=======================================================*/

/*--------------------------------------------------
 
 Synchronization
 
 -------------------------------------------------*/

/*
 Every SYNCHRONIZATION_PERIOD seconds we try to synchrnoize. 
 If the synchronize flag is set the bulletin board is updated from
 the internal datastructures.
 
 
 */


-(void) startTimer{
    [NSTimer scheduledTimerWithTimeInterval: SYNCHRONIZATION_PERIOD 
                                     target:self 
                                   selector:@selector(synchronize:) 
                                   userInfo:nil 
                                    repeats:YES];
}

-(void) stopTimer{
    [self.timer invalidate];
}

-(void) synchronize:(NSTimer *) timer{
    
//    NSLog(@"Periodic Queue: %@",((DropboxDataModel *) self.dataModel).actions);
    if (self.actionInProgress){
        NSLog(@"Synchronization postponed due to an unfinished or failed action");
        return;
    }
    if (self.needSynchronization){
        NSLog(@"==================");
        NSLog(@"Synchronizing");
        
        NSLog(@"Synchronization queue: ");
        NSLog(@"%@", ((DropboxDataModel *) self.dataModel).actions);
        self.needSynchronization = NO;
        
       // self.actionInProgress = YES;
        [DropBoxAssociativeBulletinBoard saveBulletinBoard: self];
    }
}


/*--------------------------------------------------
 
 Initialization
 
 -------------------------------------------------*/

-(id) initEmptyBulletinBoardWithDataModel:(id<DataModel>)dataModel 
                                  andName:(NSString *)bulletinBoardName{
    
    if ( [dataModel isKindOfClass:[DropboxDataModel class]]){
        ((DropboxDataModel *) dataModel).actionController = self;
    }
    self = [super initEmptyBulletinBoardWithDataModel:dataModel
                                              andName:bulletinBoardName];
    [self startTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bulletinboardDownloaded:)
                                                 name:@"bulletinboardsDownloaded" 
                                               object:nil];
    return self;
    
}

-(id) initBulletinBoardFromXoomlWithDatamodel:(id<DataModel>)dataModel
                                      andName:(NSString *)bulletinBoardName{
    self.dataModel = dataModel;
    if ( [dataModel isKindOfClass:[DropboxDataModel class]]){
        ((DropboxDataModel *) dataModel).actionController = self;
    }
    
    
    return [self initBulletinBoardFromXoomlWithName:bulletinBoardName];
}

-(id) initBulletinBoardFromXoomlWithName:(NSString *)bulletinBoardName{
    
    

    
    self = [super initBulletinBoardFromXoomlWithDatamodel:self.dataModel andName:bulletinBoardName];
    
    if ( [self.dataModel isKindOfClass:[DropboxDataModel class]]){
        ((DropboxDataModel *) self.dataModel).actionController = self;
    }
    //count the number of file to know when the download is finished
    self.fileCounter = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bulletinboardDownloaded:)
                                                 name:@"bulletinboardsDownloaded" 
                                               object:nil];
    [(DropboxDataModel <CallBackDataModel> *) self.dataModel getBulletinBoardAsynch:bulletinBoardName];
    
    //start synchronization timer
    [self startTimer];
    
    return self;
}

/*
 This methods completely initiates the bulletin board. 
 When this method is called it assumes that the bulletinboard data has been downloadded to disk so it uses disk to initiate itself. 
 */
#define NOTE_NAME @"name"
-(void) initiateBulletinBoad{
    
    NSData * bulletinBoardData = [self getBulletinBoardData];
    id bulletinBoardController= [[XoomlBulletinBoardController alloc]  initWithData:bulletinBoardData];
    
    //Make the bulletinboard controller the datasource and delegate
    //for the bulletin board so the bulletin board can structural and
    //data centric questions from it.
    self.dataSource = bulletinBoardController;
    self.delegate = bulletinBoardController;
    
    //Now start to initialize the bulletin board attributes one by one
    //from the delegate.
    
    NSDictionary * noteInfo = [self.delegate getAllNoteBasicInfo];
    
    //set up note contents
    for(NSString * noteID in noteInfo){
        
        //for each note create a note Object by reading its separate xooml files
        //from the data model
        NSString * noteName = noteInfo[noteID][NOTE_NAME];
        NSData * noteData = [self getNoteDataForNote:noteName];
        
        [self initiateNoteContent:noteData
                        forNoteID:noteID
                          andName:noteName
                    andProperties:noteInfo];
    }
    
    NSLog(@"Note Content Initiated");
    NSLog(@"-----------------------");
    //initiate Linkages
    NSLog(@"-----------------------");
    [self initiateLinkages];
    NSLog(@"Linkages initiated");
    NSLog(@"-----------------------");
    //initiate stacking
    [self initiateStacking];
    NSLog(@"Stacking initiated");
    NSLog(@"-----------------------");
    //initiate grouping
    [self initiateGrouping];
    NSLog(@"Grouping initiated");
    NSLog(@"-----------------------");
    
    
    //send notification to the notification objects 
    //so interested objects can see that the bulletinboard is loaded
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BulletinBoardLoaded"
                                                        object:self];
    
}



/*--------------------------------------------------
 
Notification
 
 -------------------------------------------------*/

-(void)bulletinboardDownloaded: (NSNotification *) notification{
    
    [self initiateBulletinBoad];
}
/*--------------------------------------------------
 
 Query
 
 -------------------------------------------------*/

-(NSData *) getBulletinBoardData{
    
    NSString * path = [FileSystemHelper getPathForBulletinBoardWithName:self.bulletinBoardName];
    NSError * err;
    NSString *data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (!data){
        NSLog(@"Failed to read file from disk: %@", err);
        return nil;
    }
    
    NSLog(@"BulletinBoard : %@ read successful", self.bulletinBoardName);
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
    
}

-(NSData *) getNoteDataForNote: (NSString *) noteName{
    
    
    NSString * path = [FileSystemHelper getPathForNoteWithName:noteName inBulletinBoardWithName:self.bulletinBoardName];
    NSError * err;
    NSString *data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    if (!data){
        NSLog(@"Failed to read  note file from disk: %@", err);
        return nil;
    }
    
    NSLog(@"Note: %@ read Successful", noteName);
    
    return [data dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *) getImageDataForPath: (NSString *) path{
    NSError * err;
    NSData * data = [NSData dataWithContentsOfFile:path];
    if (!data){
        NSLog(@"Failed to read  image %@ ile from disk: %@", path,err);
        return nil;
    }
    
    NSLog(@"image: %@ read Successful", [path lastPathComponent]);
    
    return data;
    
}
/*--------------------------------------------------
 
 Creation
 
 -------------------------------------------------*/

/*
 For the rest of the methods we use the parent methods. 
 However those methods that change only and only the bulletin board require later synchronization.
 In those cases we set the synchronization flag. 
 Note that notes that are changed directly without the bulletin board : for example changing the
 contnets of a note, do not require synchronization cause the changes gets saved in dropbox as
 soon as they happen. 
 */

-(void) addNoteContent: (id <Note>) note 
         andProperties: (NSDictionary *) properties{

    [super addNoteContent:note andProperties:properties];
    
    self.actionInProgress = YES;
    self.needSynchronization = YES;
}

- (void) addImageNoteContent:(id <Note> )noteItem 
               andProperties:noteProperties
                    andImage: (NSData *) img{
    [super addImageNoteContent:noteItem andProperties:noteProperties andImage:img];
    
    self.actionInProgress = YES;
    self.needSynchronization = YES;
    
}

-(void) addNoteAttribute: (NSString *) attributeName
        forAttributeType: (NSString *) attributeType
                 forNote: (NSString *) noteID 
               andValues: (NSArray *) values{
    [super addNoteAttribute:attributeName
           forAttributeType:attributeType 
                    forNote:noteID 
                  andValues:values];
    
    
    self.needSynchronization = YES;
}

-(void) addNote: (NSString *) targetNoteID
toAttributeName: (NSString *) attributeName
forAttributeType: (NSString *) attributeType
         ofNote: (NSString *) sourceNoteId{
    [super addNote:targetNoteID 
   toAttributeName:attributeName 
  forAttributeType:attributeType 
            ofNote:sourceNoteId];
    
    self.needSynchronization = YES;
}

-(void) addNoteWithID:(NSString *)noteID 
toBulletinBoardAttribute:(NSString *)attributeName 
     forAttributeType:(NSString *)attributeType{
    [super addNoteWithID:noteID 
toBulletinBoardAttribute:attributeName
        forAttributeType:attributeType];
    

    self.needSynchronization = YES;
}

/*--------------------------------------------------
 
 Deletion
 
 -------------------------------------------------*/

-(void) removeNoteWithID:(NSString *)delNoteID{
    [super removeNoteWithID:delNoteID];
    
    self.actionInProgress = YES;
    self.needSynchronization = true;
}

-(void) removeNote: (NSString *) targetNoteID
     fromAttribute: (NSString *) attributeName
            ofType: (NSString *) attributeType
  fromAttributesOf: (NSString *) sourceNoteID{
    [super removeNote:targetNoteID 
        fromAttribute:attributeName 
               ofType:attributeType 
     fromAttributesOf:sourceNoteID];
    

    self.needSynchronization = YES;
}

-(void) removeNoteAttribute: (NSString *) attributeName
                     ofType: (NSString *) attributeType
                   FromNote: (NSString *) noteID{
    [super removeNoteAttribute:attributeName 
                        ofType:attributeType 
                      FromNote:noteID];
    

    self.needSynchronization = YES;
}

-(void) removeNote: (NSString *) noteID
fromBulletinBoardAttribute: (NSString *) attributeName 
            ofType: (NSString *) attributeType{
    [super removeNote:noteID 
fromBulletinBoardAttribute:attributeName
               ofType:attributeType];
    

    self.needSynchronization = YES;
}

-(void) removeBulletinBoardAttribute:(NSString *)attributeName 
                              ofType:(NSString *)attributeType{
    [super removeBulletinBoardAttribute:attributeName 
                                 ofType:attributeType];

    self.needSynchronization = YES;
}


/*--------------------------------------------------
 
 Update 
 
 -------------------------------------------------*/

-(void) renameNoteAttribute: (NSString *) oldAttributeName 
                     ofType: (NSString *) attributeType
                    forNote: (NSString *) noteID 
                   withName: (NSString *) newAttributeName{
    [super renameNoteAttribute:oldAttributeName
                        ofType:attributeType
                       forNote:noteID
                      withName:newAttributeName];

    self.needSynchronization = YES;
}

-(void) updateNoteAttribute: (NSString *) attributeName
                     ofType:(NSString *) attributeType 
                    forNote: (NSString *) noteID 
              withNewValues: (NSArray *) newValues{
    [super updateNoteAttribute:attributeName
                        ofType:attributeType
                       forNote:noteID 
                 withNewValues:newValues];

    
    self.needSynchronization = YES;
}

-(void) renameBulletinBoardAttribute: (NSString *) oldAttributeNAme 
                              ofType: (NSString *) attributeType 
                            withName: (NSString *) newAttributeName{
    [super renameBulletinBoardAttribute:oldAttributeNAme
                                 ofType:attributeType 
                               withName:newAttributeName];

    self.needSynchronization = YES;
}


-(void) updateNoteAttributes:(NSString *)noteID withAttributes:(NSDictionary *)newProperties{
    [super updateNoteAttributes:noteID withAttributes:newProperties];

    self.needSynchronization = YES;
}


/*--------------------------------------------------
 
 Query
 
 -------------------------------------------------*/

-(NSDictionary *) getAllNoteImages{
    NSMutableDictionary * images = [[NSMutableDictionary alloc] init];
    for (NSString * noteID in self.noteImages){
        
        NSString * imgPath = (self.noteImages)[noteID];
        NSData * imgData = [self getImageDataForPath:imgPath];
        if (imgData != nil){
            images[noteID] = imgData;
        }
    }
    return images;
}


/*-------------------------------------------
 
 Clean up
 -------------------------------------------*/

-(void) cleanUp{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
