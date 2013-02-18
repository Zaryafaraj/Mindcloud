//
//  NoteFragmentResolver.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NoteFragmentResolver.h"
@interface NoteFragmentResolver()

//keyed on noteId and valued on noteContent -> id<NoteProtocol>
@property (strong, atomic) NSMutableDictionary * noteContentsDownloaded;
//keyed on noteId and valued on noteModel -> XoomlNoteModel
@property (strong, atomic) NSMutableDictionary * noteModelsDownloaded;
//keyed on noteId and valued on imagePath --> NSString
@property (strong, atomic) NSMutableDictionary * imagesDownloaded;

@property (strong, atomic) NSString * collectionName;

@end

@implementation NoteFragmentResolver

-(id) initWithCollectionName:(NSString *)collectionName
{
    self = [super init];
    self.collectionName = collectionName;
    self.noteContentsDownloaded = [NSMutableDictionary dictionary];
    self.noteModelsDownloaded = [NSMutableDictionary dictionary];
    self.imagesDownloaded = [NSMutableDictionary dictionary];
    return self;
}

-(void) noteContentReceived:(id<NoteProtocol>)noteContent
                  forNoteId:(NSString *)noteId
{
    
            //this means that the manifest have been processed before
            if (self.notesExpectedToBeDownloaded[noteId])
            {
                //if the note has an image we still need one more piece of the puzzle
                if (noteObj.image)
                {
                   //if we already have the image the puzzle is complete
                    if (self.imagesAlreadyDownloaded[noteId])
                    {
                        NSString * imagePath = self.imagesAlreadyDownloaded[noteId];
                    }
                    
                }
                else
                {
                    XoomlNoteModel * noteModel = self.notesExpectedToBeDownloaded[noteId];
                    self.noteAttributes[noteId] = noteModel;
                    self.noteContents[noteId] = noteObj;
                    [self.notesExpectedToBeDownloaded removeObjectForKey:noteId];
                    
                    NSDictionary * userInfo =  @{@"result" :  @[noteId]};
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_ADDED_EVENT
                                                                        object:self
                                                                      userInfo:userInfo];
                }
            }
            //this means that the manfiest has not been processed yet and we have to wait for it
            //just put yourself here and when the manifest is processed it will pick this up
            else
            {
                
                self.notesAlreadyDownloaded[noteId] = noteObj;
                
            }
}

-(void) noteModelReceived:(XoomlNoteModel *)noteModel
                forNoteId:(NSString *)noteId
{
    
        //everything is set and we have the last missing piece of the information
        //update the model and send notification for UI
        if (self.notesAlreadyDownloaded[noteId])
        {
            id<NoteProtocol> noteObj = self.notesAlreadyDownloaded[noteId];
            self.noteAttributes[noteId] = noteModel;
            self.noteContents[noteId] = noteObj;
            [self.notesAlreadyDownloaded removeObjectForKey:noteId];
            [addedNotes addObject:noteId];
        }
        //we still have to wait for the note to be downloaded. Save the state so far
        //until the download event of the note picks it up
        else
        {
            self.notesExpectedToBeDownloaded[noteId] = noteModel;
        }
}

-(void) noteImagePathReceived:(NSString *)imagePath
                    forNoteId:(NSString *)noteId
{
    
            //if this is not an update:
            //the note content has been arrived before
            if(self.imageNotesAlreadyDownloaded[noteId])
            {
                id<NoteProtocol> noteObj = self.imageNotesAlreadyDownloaded[noteId];
                self.noteImages[noteId] = imagePath;
                [self.thumbnailStack addObject:noteId];
                [self.imageNotesAlreadyDownloaded removeObjectForKey:noteId];
                //send a notification
                [[NSNo]]
            }
            else
            {
                self.imagesAlreadyDownloaded[noteId] = imagePath;
            }
}

@end
