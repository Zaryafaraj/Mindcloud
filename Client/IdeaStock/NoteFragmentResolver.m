//
//  NoteFragmentResolver.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "NoteFragmentResolver.h"
#import "NoteResolutionNotification.h"
#import "EventTypes.h"

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
    if (self.noteModelsDownloaded[noteId])
    {
        //if the note has an image we still need one more piece of the puzzle
        if (noteContent.image)
        {
           //if we already have the image the puzzle is complete
            if (self.imagesDownloaded[noteId])
            {
                NSString * imagePath = self.imagesDownloaded[noteId];
                NoteResolutionNotification * notification = [[NoteResolutionNotification alloc] initWithNoteModel:self.noteModelsDownloaded[noteId]
                                                                                                   andNoteContent:noteContent
                                                                                                     andImagePath:imagePath
                                                                                                forCollectionName:self.collectionName
                                                                                                        andNoteId:noteId];
                
                [self removeNoteFromResolver:noteId];
                NSDictionary * userInfo = @{@"result" : notification};
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_RESOLVED_EVENT
                                                                    object:self
                                                                  userInfo:userInfo];
            }
            else
            {
                //we have to still wait for the image
                self.noteContentsDownloaded[noteId] = noteContent;
            }
        }
        //not is not an image
        else
        {
            NoteResolutionNotification * notification = [[NoteResolutionNotification alloc] initWithNoteModel:self.noteModelsDownloaded[noteId]
                                                                                               andNoteContent:noteContent
                                                                                            forCollectionName:self.collectionName
                                                                                                    andNoteId:noteId];
            [self removeNoteFromResolver:noteId];
            NSDictionary * userInfo = @{@"result" : notification};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_RESOLVED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
        }
    }
    //note doesn't have its model so save the state and wait for the model to arrive
    else
    {
        self.noteContentsDownloaded[noteId] = noteContent;
    }
}

-(void) noteModelReceived:(XoomlNoteModel *)noteModel
                forNoteId:(NSString *)noteId
{
    
    //we have the note content
    if (self.noteContentsDownloaded[noteId])
    {
        
        id<NoteProtocol> noteObj = self.noteContentsDownloaded[noteId];
        //if the note needs the image we still have one more piece of the puzzle
        if (noteObj.image)
        {
            //we have everything we need and we are ready to go
            if (self.imagesDownloaded[noteId])
            {
                NSString * imagePath = self.imagesDownloaded[noteId];
                NoteResolutionNotification * notification = [[NoteResolutionNotification alloc] initWithNoteModel:noteModel
                                                                                                   andNoteContent:noteObj
                                                                                                     andImagePath:imagePath
                                                                                                forCollectionName:self.collectionName
                                                                                                        andNoteId:noteId];
                
                [self removeNoteFromResolver:noteId];
                NSDictionary * userInfo = @{@"result" : notification};
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_RESOLVED_EVENT
                                                                    object:self
                                                                  userInfo:userInfo];
            }
            //we don't have everything we need and need to wait for the image
            {
                self.noteModelsDownloaded[noteId] = noteModel;
            }
        }
        //note is not an image so we have everything we need
        else
        {
            NoteResolutionNotification * notification = [[NoteResolutionNotification alloc] initWithNoteModel:noteModel
                                                                                               andNoteContent:noteObj
                                                                                            forCollectionName:self.collectionName
                                                                                                    andNoteId:noteId];
            [self removeNoteFromResolver:noteId];
            NSDictionary * userInfo = @{@"result" : notification};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_RESOLVED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
        }
    }
    //we don't have the note content so we need to wait
    else
    {
        self.noteModelsDownloaded[noteId] = noteModel;
    }
}

-(void) noteImagePathReceived:(NSString *)imagePath
                    forNoteId:(NSString *)noteId
{
    
    if (self.noteContentsDownloaded[noteId])
    {
        if (self.noteModelsDownloaded[noteId])
        {
            //all the info is here
            NoteResolutionNotification * notification = [[NoteResolutionNotification alloc] initWithNoteModel:self.noteModelsDownloaded[noteId]
                                                                                               andNoteContent:self.noteContentsDownloaded[noteId]
                                                                                                 andImagePath:imagePath
                                                                                            forCollectionName:self.collectionName
                                                                                                    andNoteId:noteId];
            
            [self removeNoteFromResolver:noteId];
            NSDictionary * userInfo = @{@"result" : notification};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTE_RESOLVED_EVENT
                                                                object:self
                                                              userInfo:userInfo];
            
        }
        else
        {
            //we still need more ingo
            self.imagesDownloaded[noteId] = imagePath;
        }
        
    }
    //not all the info is here
    else
    {
        self.imagesDownloaded[noteId] = imagePath;
    }
}

-(void) removeNoteFromResolver:(NSString *) noteId
{
    
    [self.noteContentsDownloaded removeObjectForKey:noteId];
    [self.noteModelsDownloaded removeObjectForKey:noteId];
    [self.imagesDownloaded removeObjectForKey:noteId];
}

@end
