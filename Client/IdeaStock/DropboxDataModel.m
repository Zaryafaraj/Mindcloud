//
//  DropboxDataModel.m
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "DropboxDataModel.h"
#import "FileSystemHelper.h"
#import "DropboxAction.h"
#import "XoomlManifestParser.h"

#define ADD_BULLETIN_BOARD_ACTION @"addBulletinBoard"
#define UPDATE_BULLETIN_BOARD_ACTION @"updateBulletinBoard"
#define ADD_NOTE_ACTION @"addNote"
#define UPDATE_NOTE_ACTION @"updateNote"
#define ADD_IMAGE_NOTE_ACTION @"addImage"
#define GET_ALL_BULLETINBOARDS_ACTION @"getAllBulletinBoards"
#define GET_BULLETINBOARD_ACTION @"getBulletinBoard"
#define ACTION_TYPE_CREATE_FOLDER @"createFolder"
#define ACTION_TYPE_UPLOAD_FILE @"uploadFile"
#define ACTION_TYPE_GET_METADATA @"getMetadata"
#define ACTION_TYPE_LOAD_FILE @"loadFile"


@interface DropboxDataModel()

/*--------------------------------------------------
 
 Delegation Properties
 
 -------------------------------------------------*/

//connection to dropbox

/*--------------------------------------------------
 
 Operational Properties
 
 -------------------------------------------------*/
@property int fileCounter;


@end

/*=======================================================*/

@implementation DropboxDataModel

/*--------------------------------------------------
 
 Synthesis
 
 -------------------------------------------------*/

@synthesize restClient = _restClient;

@synthesize actionController = _actionController;
@synthesize actions = _actions;

@synthesize fileCounter = _fileCounter;

-(DBRestClient *) restClient{
    if (!_restClient){
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        
        //the default is that the data model sets itself as delegate
        _restClient.delegate = self;
    }
    return _restClient;
}

-(void) setDelegate:(id <QueueProducer,DBRestClientDelegate>)delegate{
    self.restClient.delegate = delegate;
}

-(id) delegate{
    return  _restClient.delegate;
}

-(NSMutableDictionary *) actions{
    if (!_actions){
        _actions = [[NSMutableDictionary alloc] init];
    }
    return _actions;
}

/*=======================================================*/

/*--------------------------------------------------
 
 Local file system methods
 
 -------------------------------------------------*/


/*--------------------------------------------------
 
 Creastion Methods
 
 -------------------------------------------------*/

#define BULLETINBOARD_XOOML_FILE_NAME @"XooML.xml"
-(void) addCollectionWithName: (NSString *) bulletinBoardName
            andContent: (NSData *) content{
    
    
    //first write the new content to the disk
    
    NSError * err;
    NSString * path = [FileSystemHelper getPathForCollectionWithName:bulletinBoardName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    BOOL didWrite = [content writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    
    
    //set the action
    
    if (!(self.actions)[ACTION_TYPE_CREATE_FOLDER]){
        (self.actions)[ACTION_TYPE_CREATE_FOLDER] = [[NSMutableDictionary alloc] init];
    }
    
    DropboxAction * action = [[DropboxAction alloc] init];
    action.action = ADD_BULLETIN_BOARD_ACTION;
    action.actionPath = path;
    action.actionBulletinBoardName = bulletinBoardName;
    
    NSString * folderName = [@"/" stringByAppendingString: bulletinBoardName];
    (self.actions)[ACTION_TYPE_CREATE_FOLDER][folderName] = action;
    
    //now create a folder in dropbox the rest is done by the foldercreated delegate method
    [self.restClient createFolder:folderName];
}

-(void) addNote: (NSString *)noteName 
    withContent: (NSData *) note 
ToCollection: (NSString *) bulletinBoardName{
    
    NSError * err;
    //first write the note to the disk
    NSString * path = [FileSystemHelper getPathForNoteWithName:noteName inCollectionWithName:bulletinBoardName];
    
    [FileSystemHelper createMissingDirectoryForPath:path];
    BOOL didWrite = [note writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    
    //now upload the file to the dropbox
    //First check whether the note folder exists
    //NSString * destination = [NSString stringWithFormat: @"/%@/%@/%@", bulletinBoardName, noteName, NOTE_XOOML_FILE_NAME];
    NSString * destination = [NSString stringWithFormat: @"/%@/%@", bulletinBoardName, noteName];
    
    
    if (!(self.actions)[ACTION_TYPE_CREATE_FOLDER]){
        (self.actions)[ACTION_TYPE_CREATE_FOLDER] = [[NSMutableDictionary alloc] init];
    }
    
    DropboxAction * action = [[DropboxAction alloc] init];
    action.action = ADD_NOTE_ACTION;
    action.actionPath = path;
    action.actionBulletinBoardName = bulletinBoardName;
    action.actionNoteName = noteName;
    
    NSString * folderName = destination;
    (self.actions)[ACTION_TYPE_CREATE_FOLDER][folderName] = action;
    
    //the rest is done for loadedMetadata method
    [self.restClient createFolder: destination];
    
}


-(void) addImageNote: (NSString *) noteName 
     withNoteContent: (NSData *) note 
            andImage: (NSData *) img 
   withImageFileName:(NSString *)imgName
     toCollection: (NSString *) bulletinBoardName{
    
    
    NSError * err;
    NSString * notePath = [FileSystemHelper getPathForNoteWithName:noteName inCollectionWithName:bulletinBoardName];
    
    if (!(self.actions)[ACTION_TYPE_CREATE_FOLDER]){
        (self.actions)[ACTION_TYPE_CREATE_FOLDER] = [[NSMutableDictionary alloc] init];
    }
    
    
    
    [FileSystemHelper createMissingDirectoryForPath:notePath];
    BOOL didWrite = [note writeToFile:notePath options:NSDataWritingAtomic error:&err];
    
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    NSString *path = [notePath stringByDeletingLastPathComponent];
    path = [path stringByAppendingFormat:@"/%@",imgName];
    
    didWrite = [img writeToFile:path options:NSDataWritingAtomic error:&err];
    
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    
    DropboxAction * action = [[DropboxAction alloc] init];
    action.actionPath = notePath;
    action.action = ADD_IMAGE_NOTE_ACTION;
    action.actionBulletinBoardName = bulletinBoardName;
    action.actionNoteName = noteName;
    action.actionFileName =imgName;
    
    NSString * folderName = [NSString stringWithFormat: @"/%@/%@", bulletinBoardName, noteName];
    (self.actions)[ACTION_TYPE_CREATE_FOLDER][folderName] = action;
    //the rest is done for loadedMetadata method
    [self.restClient createFolder: folderName];
}
/*--------------------------------------------------
 
 Update Methods
 
 -------------------------------------------------*/

-(void) updateCollectionWithName: (NSString *) bulletinBoardName 
               andContent: (NSData *) content{
    [self.actionController setActionInProgress:NO];
    
    
    NSError * err;
    NSString * path = [FileSystemHelper getPathForCollectionWithName:bulletinBoardName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    
    BOOL didWrite = [content writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    if (!(self.actions)[ACTION_TYPE_GET_METADATA]){
        (self.actions)[ACTION_TYPE_GET_METADATA] = [[NSMutableDictionary alloc] init];
    }
    
    //set the action
    DropboxAction * action = [[DropboxAction alloc] init];
    action.action = UPDATE_BULLETIN_BOARD_ACTION;
    action.actionPath = path;
    action.actionBulletinBoardName = bulletinBoardName;
    
    //now update the bulletin board. No need to create any folders 
    //because we are assuming its always there.
    //To update we need to know the latest revision number by calling metadata
    NSString * folder = [NSString stringWithFormat:@"/%@/%@",bulletinBoardName,BULLETINBOARD_XOOML_FILE_NAME];
    
    (self.actions)[ACTION_TYPE_GET_METADATA][folder] = action;
    
    [self.restClient loadMetadata:folder];
    
    
}
#define NOTE_XOOML_FILE_NAME @"XooML.xml"

-(void) updateNote: (NSString *) noteName 
       withContent: (NSData *) content
   inCollection:(NSString *) bulletinBoardName{
    
    NSError *err;
    NSString *path = [FileSystemHelper getPathForNoteWithName:noteName inCollectionWithName:bulletinBoardName];
    [FileSystemHelper createMissingDirectoryForPath:path];
    
    BOOL didWrite = [content writeToFile:path options:NSDataWritingAtomic error:&err];
    if (!didWrite){
        NSLog(@"Error in writing to file system: %@", err);
        return;
    }
    
    if (!(self.actions)[ACTION_TYPE_GET_METADATA]){
        (self.actions)[ACTION_TYPE_GET_METADATA] = [[NSMutableDictionary alloc] init];
    }
    
    DropboxAction * action = [[DropboxAction alloc] init];
    //set the action
    action.action = UPDATE_NOTE_ACTION;
    action.actionPath = path;
    action.actionBulletinBoardName = bulletinBoardName;
    
    //now update the bulletin board. No need to create any folders 
    //because we are assuming its always there.
    //To update we need to know the latest revision number by calling metadata
    
    NSString * folder = [NSString stringWithFormat:@"/%@/%@/%@",bulletinBoardName,noteName, NOTE_XOOML_FILE_NAME];
    
    (self.actions)[ACTION_TYPE_GET_METADATA][folder] = action;
    [self.restClient loadMetadata:folder];
    
}

/*--------------------------------------------------
 
 Deletion Methods
 
 -------------------------------------------------*/


-(void) removeCollection:(NSString *) boardName{
    
    NSError * err;
    NSString * path = [FileSystemHelper getPathForCollectionWithName:boardName];
    path = [path stringByDeletingLastPathComponent];
    NSFileManager * manager = [NSFileManager defaultManager];
    BOOL didDelete = [manager removeItemAtPath:path error:&err];
    
    //its okey if this is not on the disk and we have an error
    //try dropbox and see if you can delete it from there
    if (!didDelete){
        NSLog(@"Error in deleting the file from the disk: %@",err);
        NSLog(@"Trying to delete from dropbox...");
    }
    
    [self.restClient deletePath:boardName];
    
}

-(void) removeNote: (NSString *) noteName
 FromCollection: (NSString *) bulletinBoardName{
    
    
     NSError *err;
     NSString * path = [[FileSystemHelper getPathForNoteWithName:noteName inCollectionWithName:bulletinBoardName] stringByDeletingLastPathComponent];
     NSFileManager * manager = [NSFileManager defaultManager];
     BOOL didDelete = [manager removeItemAtPath:path error:&err];
     
     //its okey if this is not on the disk and we have an error
     //try dropbox and see if you can delete it from there
     if (!didDelete){
     NSLog(@"Error in deleting the file from the disk: %@",err);
     NSLog(@"Trying to delete from dropbox...");
     }
     
     NSString * delPath = [bulletinBoardName stringByAppendingFormat:@"/%@",noteName];
     [self.restClient deletePath:delPath];
     
    
}

/*--------------------------------------------------
 
 Query Methods
 
 -------------------------------------------------*/

-(NSArray *) getAllCollections{
    [self getAllBulletinBoardsAsynch];
    return nil;
}

-(NSData *) getCollection: (NSString *) bulletinBoardName{
    [self getBulletinBoardAsynch:bulletinBoardName];
    return nil;
}

-(void) getAllBulletinBoardsAsynch{
    
    if (!(self.actions)[ACTION_TYPE_GET_METADATA]){
        (self.actions)[ACTION_TYPE_GET_METADATA] = [[NSMutableDictionary alloc] init];
    }
    
    DropboxAction * action = [[DropboxAction alloc] init];
    action.action = GET_ALL_BULLETINBOARDS_ACTION;
    
    NSString * folder = @"/";;
    (self.actions)[ACTION_TYPE_GET_METADATA][folder] = action;
    [self.restClient loadMetadata:folder];
}

-(void) getBulletinBoardAsynch: (NSString *) bulletinBoardName{
    
    if (!(self.actions)[ACTION_TYPE_GET_METADATA]){
        (self.actions)[ACTION_TYPE_GET_METADATA] = [[NSMutableDictionary alloc] init];
    }
    
    DropboxAction * action = [[DropboxAction alloc] init];
    action.action = GET_BULLETINBOARD_ACTION;
    
    NSString * folder =[NSString stringWithFormat: @"/%@", bulletinBoardName];
    (self.actions)[ACTION_TYPE_GET_METADATA][folder] = action;
    [[self restClient] loadMetadata:folder];
    
}

/*--------------------------------------------------
 
 RESTClient delegate protocol
 
 -------------------------------------------------*/

-(void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    
    NSString * parentRev = [metadata rev];
    NSString * path = [metadata path];
    
    DropboxAction * actionItem;
    if ((self.actions)[ACTION_TYPE_GET_METADATA]){
        NSString * folderName = path;
        //NSString * folderName = [path lastPathComponent];

        if ((self.actions)[ACTION_TYPE_GET_METADATA][folderName] || 
            (self.actions)[ACTION_TYPE_GET_METADATA][[@"/" stringByAppendingString:folderName]]){
            
            actionItem = (self.actions)[ACTION_TYPE_GET_METADATA][folderName];
            if (actionItem == nil){
                actionItem = actionItem = (self.actions)[ACTION_TYPE_GET_METADATA][[@"/" stringByAppendingString:folderName]];
            }
            
            [(self.actions)[ACTION_TYPE_GET_METADATA] removeObjectForKey:folderName];
        }
    }
    
    NSLog(@"Meta data loaded");
    
    if( [actionItem.action isEqualToString:UPDATE_BULLETIN_BOARD_ACTION] ){
        
        NSLog(@"Performing Update Bulletin board action");
        
        NSString * sourcePath = actionItem.actionPath;
        
        path = [path stringByDeletingLastPathComponent];
        
        NSLog(@"Uploading file: %@ to destination: %@", sourcePath, path);
        
        DropboxAction * newAction = [[DropboxAction alloc] init];
        newAction.action = UPDATE_BULLETIN_BOARD_ACTION;
        newAction.actionPath = path;
        newAction.actionNoteName = actionItem.actionNoteName;
        newAction.actionFileName = sourcePath;
        newAction.actionBulletinBoardName = actionItem.actionBulletinBoardName;
        
        if (!(self.actions)[ACTION_TYPE_UPLOAD_FILE]){
            (self.actions)[ACTION_TYPE_UPLOAD_FILE] = [[NSMutableDictionary alloc] init];
        }
        
        (self.actions)[ACTION_TYPE_UPLOAD_FILE][path] = newAction;
        
        [self.restClient uploadFile:BULLETINBOARD_XOOML_FILE_NAME toPath:path withParentRev:parentRev fromPath:sourcePath];
        
        return;
    }
    
    if ( [actionItem.action isEqualToString:UPDATE_NOTE_ACTION]){
        
        NSLog(@"Performin Update Note Action");
        NSString * sourcePath = actionItem.actionPath;        
        
        path = [path stringByDeletingLastPathComponent];
        NSLog(@"Uploading file: %@ to destination : %@", sourcePath,path);
        
        DropboxAction * newAction = [[DropboxAction alloc] init];
        newAction.action = UPDATE_NOTE_ACTION;
        newAction.actionPath = path;
        newAction.actionNoteName = actionItem.actionNoteName;
        newAction.actionFileName = sourcePath;
        newAction.actionBulletinBoardName = actionItem.actionBulletinBoardName;

        (self.actions)[ACTION_TYPE_UPLOAD_FILE][path] = newAction;
        [self.restClient uploadFile:NOTE_XOOML_FILE_NAME toPath:path withParentRev:parentRev fromPath:sourcePath];
        
        return;
    }
    
    if ([actionItem.action isEqualToString:GET_ALL_BULLETINBOARDS_ACTION]){
        
        NSLog(@"Performing get all bulletinboards action");
        NSMutableArray * bulletinBoardNames = [[NSMutableArray alloc] init];
        for (DBMetadata * child in metadata.contents){
            if (child.isDirectory){
                NSString * name = [child.path substringFromIndex:1];
                [bulletinBoardNames addObject:name];
            }
        }
        
        NSLog(@"Read %d bulletinboards", [bulletinBoardNames count]);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BulletinboardsLoaded"
                                                            object:bulletinBoardNames];
    }
    
    if ([actionItem.action isEqualToString:GET_BULLETINBOARD_ACTION]){
        
        NSString * tempDir = [NSTemporaryDirectory() stringByDeletingPathExtension];
        
        NSString * directory = [[metadata path] lowercaseString];
        NSString * rootFolder = [tempDir stringByAppendingString:directory];
        [FileSystemHelper createMissingDirectoryForPath:rootFolder];
        //handle this error later
        NSError * err;
        NSFileManager * fileManager =  [NSFileManager defaultManager];
        
        for(DBMetadata * child in metadata.contents){
            NSString *path = [child.path lowercaseString];
            if(child.isDirectory){
                
                DropboxAction * action = [[DropboxAction alloc] init];
                action.action = GET_BULLETINBOARD_ACTION;
                (self.actions)[ACTION_TYPE_GET_METADATA][child.path] = action;
                [client loadMetadata:child.path];
                
                NSString * dir = [tempDir stringByAppendingString:path];
                NSLog(@"Creating the dir: %@", dir);
                BOOL didCreate = [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
                if (!didCreate){
                    NSLog(@"Error in creating Dir: %@",err);
                }
                
            }
            
            
            else{
                NSLog(@"Found file: %@", child.path);
                
                self.fileCounter++;
                
                NSString * destination = [tempDir stringByAppendingString:path];
                
                NSLog(@"putting file in destination: %@",destination);
                
                DropboxAction * action = [[DropboxAction alloc] init];
                action.action = GET_BULLETINBOARD_ACTION;
                if (!(self.actions)[ACTION_TYPE_LOAD_FILE]){
                    (self.actions)[ACTION_TYPE_LOAD_FILE] = [[NSMutableDictionary alloc] init];
                }
                
                NSString * folder = destination;
                if (!(self.actions)[ACTION_TYPE_LOAD_FILE]){
                    (self.actions)[ACTION_TYPE_LOAD_FILE] = [[NSMutableDictionary alloc] init];
                }
                (self.actions)[ACTION_TYPE_LOAD_FILE][folder] = action;
                [client loadFile:child.path intoPath:folder];
            }
        }

    }
}

-(void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    
    NSLog(@"Error loading metadata: %@", error);
}

-(void) restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath{
    
    NSString * destPathOrg = [destPath stringByDeletingLastPathComponent];
    if ((self.actions)[ACTION_TYPE_UPLOAD_FILE]){
        if ((self.actions)[ACTION_TYPE_UPLOAD_FILE][destPathOrg]){
            NSLog(@"Successfully Uploaded File from %@ to %@", srcPath,destPath);
            [(self.actions)[ACTION_TYPE_UPLOAD_FILE] removeObjectForKey:destPathOrg];
            NSLog(@"Remaining Actions: %@",self.actions);
            self.actionController.actionInProgress = NO;
            
        }
    }
    
}

-(void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder{
    
    DropboxAction * actionItem;
    
    if ((self.actions)[ACTION_TYPE_CREATE_FOLDER]){
        
        NSString *folderName = [folder path];
//        NSString * folderName = [[folder path] lastPathComponent];
        if ((self.actions)[ACTION_TYPE_CREATE_FOLDER][folderName]){
            actionItem = (self.actions)[ACTION_TYPE_CREATE_FOLDER][folderName];
            [(self.actions)[ACTION_TYPE_CREATE_FOLDER] removeObjectForKey:folderName];
        }
    }
    
    if ([actionItem.action isEqualToString:ADD_BULLETIN_BOARD_ACTION]){
        
        NSLog(@"Performing Add Bulletin board action");
        NSLog(@"Folder Created for bulletinboard: %@ ", actionItem.actionBulletinBoardName);
        NSString *path = [folder path];
        NSString * sourcePath = actionItem.actionPath;
        
        //since its a new file the revision is set to nil
        
        DropboxAction * newAction = [[DropboxAction alloc] init];
        newAction.action = ADD_BULLETIN_BOARD_ACTION;
        newAction.actionPath = path;
        newAction.actionFileName = BULLETINBOARD_XOOML_FILE_NAME;
        newAction.actionBulletinBoardName = actionItem.actionBulletinBoardName;
        
        if (!(self.actions)[ACTION_TYPE_UPLOAD_FILE]){
            (self.actions)[ACTION_TYPE_UPLOAD_FILE] = [[NSMutableDictionary alloc] init];
        }
        
        (self.actions)[ACTION_TYPE_UPLOAD_FILE][path] = newAction;
        
        [self.restClient uploadFile:BULLETINBOARD_XOOML_FILE_NAME toPath:path withParentRev:nil fromPath:sourcePath];
        
        [self.actionController setActionInProgress:NO];
        
        return;
        
    }
    
    
    if([actionItem.action isEqualToString:ADD_NOTE_ACTION] ||
       [actionItem.action isEqualToString:ADD_IMAGE_NOTE_ACTION]){
        NSLog(@"Performing Add Note action");
        NSLog(@"Folder Created for note: %@", actionItem.actionNoteName);
        NSString * path = [folder path];
        
        
        NSString * sourcePath = actionItem.actionPath;
        BOOL isImage = [actionItem.action isEqualToString:ADD_IMAGE_NOTE_ACTION] ? YES: NO;
        
        
        DropboxAction * newAction = [[DropboxAction alloc] init];
        newAction.action = ADD_NOTE_ACTION;
        newAction.actionPath = path;
        newAction.actionNoteName = actionItem.actionNoteName;
        newAction.actionFileName = sourcePath;
        newAction.actionBulletinBoardName = actionItem.actionBulletinBoardName;
        
        if (!(self.actions)[ACTION_TYPE_UPLOAD_FILE]){
            (self.actions)[ACTION_TYPE_UPLOAD_FILE] = [[NSMutableDictionary alloc] init];
        }
        (self.actions)[ACTION_TYPE_UPLOAD_FILE][path] = newAction;
        
        [self.restClient uploadFile:NOTE_XOOML_FILE_NAME toPath:path withParentRev:nil fromPath:sourcePath];
        
        if (isImage){
            
            NSLog(@"Note is an Image");
            NSString *imgPath = [sourcePath stringByDeletingLastPathComponent];
            imgPath = [imgPath stringByAppendingFormat:@"/%@",actionItem.actionFileName];
            NSLog(@"Uploading image file: from %@ to destination: %@", imgPath, path);
            
            DropboxAction * imageAction = [[DropboxAction alloc] init];
            imageAction.action = ADD_IMAGE_NOTE_ACTION;
            imageAction.actionPath = path;
            imageAction.actionNoteName = actionItem.actionNoteName;
            imageAction.actionFileName = actionItem.actionFileName;
            imageAction.actionBulletinBoardName = actionItem.actionBulletinBoardName;
            
            
            (self.actions)[ACTION_TYPE_UPLOAD_FILE][path] = imageAction;
            [self.actionController setActionInProgress:YES];
            [self.restClient uploadFile:actionItem.actionFileName toPath:path withParentRev:nil fromPath:imgPath];
        } 
    }
}

-(void) restClient: (DBRestClient *) client loadedFile:(NSString *)destPath{
    
    DropboxAction * actionItem;
    
    if ((self.actions)[ACTION_TYPE_LOAD_FILE]){
        
        NSString * folderName = destPath;
        //NSString * folderName = [destPath lastPathComponent];
        if ((self.actions)[ACTION_TYPE_LOAD_FILE][folderName]){
            actionItem = (self.actions)[ACTION_TYPE_LOAD_FILE][folderName];
            [(self.actions)[ACTION_TYPE_LOAD_FILE] removeObjectForKey:folderName];
        }
        [(self.actions)[ACTION_TYPE_LOAD_FILE] removeObjectForKey:folderName];
    }
    
    if ([actionItem.action isEqualToString:GET_BULLETINBOARD_ACTION]){
        //one file is loaded so reduce the counter
        self.fileCounter --;
        
        if (self.fileCounter == 0){
            //all the bulletinboard files are downloaded
            //now initialize the bulletinBoard. 
            NSLog(@"All Files Download");
            [self.actionController setActionInProgress:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"bulletinboardsDownloaded" object:self];
        }        
    }    
}
-(void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    NSLog(@"Failed to create Folder:: %@", error);
}


- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error{
    NSLog(@"Upload file failed with error: %@", error);
}


- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path{
    NSLog(@"Successfully deleted path : %@", path);
    self.actionController.actionInProgress = NO;
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error{
    NSLog(@"Failed to delete path: %@", error);
}

@end
