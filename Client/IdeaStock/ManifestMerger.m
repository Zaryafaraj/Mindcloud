//
//  ManifestMerger.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ManifestMerger.h"
#import "XoomlCollectionParser.h"
#import "XoomlCollectionManifest.h"

@interface ManifestMerger()
@property (atomic, strong) id<CollectionManifestProtocol> clientManifest;
@property (atomic, strong) id<CollectionManifestProtocol> serverManifest;
@property (atomic, strong) CollectionRecorder * recorder;
@property (atomic, strong) NotificationContainer * notifications;
@end
@implementation ManifestMerger

-(id) initWithClientManifest:(id<CollectionManifestProtocol>)clientManifest
           andServerManifest:(id<CollectionManifestProtocol>)serverManifest
           andActionRecorder:(CollectionRecorder *)recorder
{
    self = [super init];
    self.clientManifest = clientManifest;
    self.serverManifest = serverManifest;
    self.recorder = recorder;
    self.notifications = [[NotificationContainer alloc] init];
    return self;
}

-(NotificationContainer *) getNotifications
{
    return self.notifications;
}

-(id<CollectionManifestProtocol>) mergeManifests
{
    DDXMLDocument * clientXML = [self.clientManifest document];
    DDXMLDocument * serverXML = [self.serverManifest document];
    NSMutableDictionary * clientStackings = [NSMutableDictionary dictionary];
    NSMutableDictionary * clientNotes = [NSMutableDictionary dictionary];
    [self processXoomlDocument:clientXML
                 intoStackings: clientStackings
                      andNotes: clientNotes];
    
    NSMutableDictionary * serverStackings = [NSMutableDictionary dictionary];
    NSMutableDictionary * serverNotes = [NSMutableDictionary dictionary];
    [self processXoomlDocument:serverXML
                 intoStackings:serverStackings
                      andNotes:serverNotes];
    
    NSDictionary * finalStackings = [self mergeServerStacking:serverStackings
                                           withClientStacking:clientStackings];
    
    NSDictionary * finalNotes = [self mergeServerNotes: serverNotes
                                       withClientNotes: clientNotes];
    
    DDXMLElement * thumbnailElement = [self getThumbnailElement:clientXML];
    DDXMLDocument * document = [self createMergedDocumentWithNotes: finalNotes
                                                      andStackings: finalStackings
                                                      andThumbnail: thumbnailElement];
    
    id<CollectionManifestProtocol> result = [[XoomlCollectionManifest alloc] initWithDocument:document];
    return result;
}

-(NSDictionary *) mergeServerNotes:(NSDictionary *) serverNotes
                   withClientNotes:(NSDictionary *) clientNotes
{
    
    NSSet * clientNoteIds = [NSSet setWithArray:[clientNotes allKeys]];
    NSSet * serverNoteIds = [NSSet setWithArray:[serverNotes allKeys]];
    
    
    NSMutableSet * notesUniqueToClient = [NSMutableSet setWithSet:clientNoteIds];
    [notesUniqueToClient minusSet:serverNoteIds];
    NSMutableSet * notesUniqueToServer = [NSMutableSet setWithSet:serverNoteIds];
    [notesUniqueToServer minusSet:clientNoteIds];
    NSMutableSet * notesInBoth = [NSMutableSet setWithSet:clientNoteIds];
    [notesInBoth intersectSet:serverNoteIds];
    
    NSMutableDictionary * finalNotes = [NSMutableDictionary dictionary];
    //General Rule about notifications :
    // IF we are accepting something server side we should create a notification
    
    //if there is something in the server that isn't in the client; there are two possibilities:
    // 1- It has never been in the client --> its a new thing and we should add it
    // 2- It has been in the client before but was deleted ---> the client is more uptodate and
    for (NSString * noteId in notesUniqueToServer)
    {
        //accepting server side
        if (![self.recorder hasNoteBeenTouched:noteId])
        {
            //case 1
            finalNotes[noteId] = serverNotes[noteId];
            DDXMLElement * noteElement = finalNotes[noteId];
            AddNoteNotification * notification = [self createAddNoteNotification:noteElement];
            [self.notifications addAddNoteNotification:notification];
        }
        //for case 2 we don't do anything
    }
    
    //if there is something in the client that isn't in the server.there are two possibilities:
    //1- It has been in the server but got deleted --> we should not keep it
    //2- It has never been in the server and got added to the client --> we should keep it
    for(NSString * noteId in notesUniqueToClient)
    {
        //accepting client side
        if ([self.recorder hasNoteBeenTouched:noteId])
        {
            finalNotes[noteId] = clientNotes[noteId];
        }
        //accepting server side
        else
        {
            DDXMLElement * noteElement = clientNotes[noteId];
            DeleteNoteNotification * notification = [self createDeleteNoteNotification:noteElement];
            [self.notifications addDeleteNoteNotification:notification];
        }
    }
    
    //if the note is in both of them, then there are two cases:
    // 1- The item has not been touched in the client --> accept the servers
    // 2- The item has been touched in the client --> accept the client
    for(NSString * noteId in notesInBoth)
    {
        //accepting client side
        if ([self.recorder hasNoteBeenTouched:noteId])
        {
            finalNotes[noteId] = clientNotes[noteId];
        }
        //accepting server side
        else
        {
            finalNotes[noteId] = serverNotes[noteId];
            DDXMLElement * serverElement = serverNotes[noteId];
            DDXMLElement * clientElement = clientNotes[noteId];
            BOOL isServerSideDifferent = ![self isNoteElement:serverElement theSameAs:clientElement];
            if (isServerSideDifferent)
            {
                UpdateNoteNotification * notification = [self createUpdateNoteNotification:serverElement];
                [self.notifications addUpdateNoteNotification:notification];
            }
        }
    }
    return finalNotes;
}

-(NSDictionary *) mergeServerStacking:(NSDictionary *) serverStackings
         withClientStacking:(NSDictionary *) clientStackings
{
    
    NSSet * serverStackingIds = [NSSet setWithArray:[serverStackings allKeys]];
    NSSet * clientStackingIds = [NSSet setWithArray:[clientStackings allKeys]];
    NSMutableSet * stackingsUniqueToClient = [NSMutableSet setWithSet:clientStackingIds];
    [stackingsUniqueToClient minusSet:serverStackingIds];
    NSMutableSet * stackingsUniqueToServer = [NSMutableSet setWithSet:serverStackingIds];
    [stackingsUniqueToServer minusSet:clientStackingIds];
    NSMutableSet * stackingsInBoth = [NSMutableSet setWithSet:clientStackingIds];
    [stackingsInBoth intersectSet:serverStackingIds];
    NSMutableDictionary * finalStackings = [NSMutableDictionary dictionary];
    
    
    //General Rule about notifications :
    // IF we are accepting something server side we should create a notification
    
    //if there is something in the server that isn't in the client; there are two possibilities:
    // 1- It has never been in the client --> its a new thing and we should add it
    // 2- It has been in the client before but was deleted ---> the client is more uptodate and
    for (NSString * stackingId in stackingsUniqueToServer)
    {
        //accepting server side
        if (![self.recorder hasStackingBeenTouched:stackingId])
        {
            finalStackings[stackingId] = serverStackings[stackingId];
            DDXMLElement * stackingElement = finalStackings[stackingId];
            AddStackingNotification * notification = [self createAddStackingNotification: stackingElement];
            [self.notifications addAddStackingNotification:notification];
        }
    }
    
    //if there is something in the client that isn't in the server.there are two possibilities:
    //1- It has been in the server but got deleted by someone else --> we should not keep it
    //2- It has never been in the server and got added to the client --> we should keep it
    for(NSString * stackingId in stackingsUniqueToClient)
    {
        //accepting client side
        if ([self.recorder hasStackingBeenTouched:stackingId])
        {
            finalStackings[stackingId] = clientStackings[stackingId];
        }
        //accepting server side, which is deleting the client side
        else
        {
            DDXMLElement * stackingElement = clientStackings[stackingId];
            DeleteStackingNotification * notification = [self createDeleteStackingNotification:stackingElement];
            [self.notifications addDeleteStackingNotification:notification];
        }
    }
    
    //if the note is in both of them, then there are two cases:
    // 1- The item has not been touched in the client --> accept the servers
    // 2- The item has been touched in the client --> accept the client
    for(NSString * stackingId in stackingsInBoth)
    {
        //accepting client side
        if ([self.recorder hasStackingBeenTouched:stackingId])
        {
            finalStackings[stackingId] = clientStackings[stackingId];
        }
        //accepting server side
        else
        {
            finalStackings[stackingId] = serverStackings[stackingId];
            DDXMLElement * serverElement = serverStackings[stackingId];
            DDXMLElement * clientElement = clientStackings[stackingId];
            BOOL isServerSideDifferent = ![self isStackingElement: serverElement theSameAs: clientElement];
            if (isServerSideDifferent)
            {
                UpdateStackNotification * notification = [self createUpdateStackingNotification:serverElement];
                [self.notifications addUpdateStackingNotification:notification];
            }
        }
    }
    return finalStackings;
}
-(void) processXoomlDocument:(DDXMLDocument *) doc
               intoStackings: (NSMutableDictionary *) stackings
                    andNotes:(NSMutableDictionary *) notes
{
    
    for (DDXMLElement * node in doc.rootElement.children)
    {
        if ([node.name isEqualToString:FRAGMENT_NAMESPACE_DATA])
        {
            //process all the stackings
            for(DDXMLElement * stackingElement in node.children)
            {
                NSString * elementType = [[stackingElement attributeForName:ATTRIBUTE_TYPE] stringValue];
                if ([stackingElement.name isEqualToString:MINDCLOUD_COLLECTION_ATTRIBUTE] &&
                    [elementType isEqualToString:STACKING_TYPE])
                {
                    NSString * stackingId = [[stackingElement attributeForName:ATTRIBUTE_ID] stringValue];
                    if (stackingId)
                    {
                        stackings[stackingId] = stackingElement;
                    }
                }
            }
        }
        else if ([node.name isEqualToString:XOOML_ASSOCIATION])
        {
            NSString * noteId = [[node attributeForName:ATTRIBUTE_ID] stringValue];
            notes[noteId] = node;
        }
    }
}

-(AddStackingNotification *) createAddStackingNotification:(DDXMLElement *) stackingXml
{
    NSString * stackingName = [[stackingXml attributeForName:ATTRIBUTE_NAME] stringValue];
    NSString *  stackingScale = [[stackingXml attributeForName:SCALING] stringValue];
    NSMutableArray * refNotesArray = [NSMutableArray array];
    for (DDXMLElement *refIDElem in [stackingXml children]){
        NSString * refID = [[refIDElem attributeForName:REF_ID] stringValue];
        [refNotesArray addObject:refID];
    }
    
    AddStackingNotification * result = [[AddStackingNotification alloc] initWithStackingId:stackingName
                                                                                  andScale:stackingScale
                                                                               andNoteRefs:refNotesArray];
    return result;
}

-(DeleteStackingNotification *) createDeleteStackingNotification:(DDXMLElement *) stackingXml
{
    NSString * stackingName = [[stackingXml attributeForName:ATTRIBUTE_NAME] stringValue];
    DeleteStackingNotification * result = [[DeleteStackingNotification alloc] initWithStackingId:stackingName];
    return result;
}

-(UpdateStackNotification *) createUpdateStackingNotification:(DDXMLElement *) stackingXml
{
    
    NSString * stackingName = [[stackingXml attributeForName:ATTRIBUTE_NAME] stringValue];
    NSString *  stackingScale = [[stackingXml attributeForName:SCALING] stringValue];
    NSMutableArray * refNotesArray = [NSMutableArray array];
    for (DDXMLElement *refIDElem in [stackingXml children]){
        NSString * refID = [[refIDElem attributeForName:REF_ID] stringValue];
        [refNotesArray addObject:refID];
    }
    
    UpdateStackNotification * result = [[UpdateStackNotification alloc] initWithStackId:stackingName
                                                                               andScale:stackingScale
                                                                            andNoteRefs:refNotesArray];
    return result;
}

-(BOOL) isStackingElement:(DDXMLElement *) stackingXml1
                theSameAs:(DDXMLElement *) stackingXml2
{
    NSString * stackingName1 = [[stackingXml1 attributeForName:ATTRIBUTE_NAME] stringValue];
    NSString * stackingName2 = [[stackingXml2 attributeForName:ATTRIBUTE_NAME] stringValue];
    if (![stackingName1 isEqualToString:stackingName2])
    {
        return NO;
    }
    
    NSString *  stackingScale1 = [[stackingXml1 attributeForName:SCALING] stringValue];
    NSString *  stackingScale2 = [[stackingXml2 attributeForName:SCALING] stringValue];
    if (![stackingScale1 isEqualToString:stackingScale2])
    {
        return NO;
    }
    
    NSMutableSet * refNotes1 = [NSMutableSet set];
    for (DDXMLElement *refIDElem in [stackingXml1 children]){
        NSString * refID = [[refIDElem attributeForName:REF_ID] stringValue];
        [refNotes1 addObject:refID];
    }
    NSMutableSet * refNotes2 = [NSMutableSet set];
    for (DDXMLElement *refIDElem in [stackingXml2 children]){
        NSString * refID = [[refIDElem attributeForName:REF_ID] stringValue];
        [refNotes2 addObject:refID];
    }
    
    if (![refNotes1 isEqualToSet:refNotes2])
    {
        return NO;
    }
    
    return YES;
    
}

-(AddNoteNotification *) createAddNoteNotification:(DDXMLElement *) noteXml
{
    NSString * noteId = [[noteXml attributeForName:ATTRIBUTE_ID] stringValue];
    NSString * positionX = @"0";
    NSString * positionY = @"0";
    NSString * scale = @"1";
    for (DDXMLElement * node in noteXml.children)
    {
        if ([node.name isEqualToString:ASSOCIATION_NAMESPACE_DATA])
        {
            for (DDXMLElement * noteProp in node.children)
            {
                if ([noteProp.name isEqualToString:MINDCLOUD_NOTE_ATTRIBUTE])
                {
                    if ([[[noteProp attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:MINDCLOUD_NOTE_POSITION_ATTRIBUTE_TYPE])
                    {
                        positionX = [[noteProp attributeForName:POSITION_X] stringValue];
                        positionY = [[noteProp attributeForName:POSITION_Y] stringValue];
                    }
                    else if ([[[noteProp attributeForName:ATTRIBUTE_TYPE] stringValue] isEqualToString:MINDCLOUD_NOTE_SCALE_ATTRIBUTE_TYPE])
                    {
                        
                        scale = [[noteProp attributeForName:SCALING] stringValue];
                    }
                }
            }
        }
    }
    
    AddNoteNotification * result = [[AddNoteNotification alloc] initWithNoteId:noteId
                                                                  andPositionX:positionX
                                                                  andPositionY:positionY
                                                                    andScaling:scale];
    return result;
}

-(DeleteNoteNotification *) createDeleteNoteNotification:(DDXMLElement *) noteXml
{
    NSString * noteId = [[noteXml attributeForName:ATTRIBUTE_ID] stringValue];
    DeleteNoteNotification * result = [[DeleteNoteNotification alloc] initWithNoteId:noteId];
    return result;
}

-(UpdateNoteNotification *) createUpdateNoteNotification:(DDXMLElement *) noteXml
{
    
    AddNoteNotification * temp = [self createAddNoteNotification:noteXml];
    
    UpdateNoteNotification * result = [[UpdateNoteNotification alloc] initWithNoteId:temp.getNoteId
                                                                        andPositionX:temp.getPositionX
                                                                        andPositionY:temp.getPositionY
                                                                            andScale:temp.getScale];
    return result;
}

-(BOOL) isNoteElement:(DDXMLElement *) noteXml1
            theSameAs:(DDXMLElement *) noteXml2
{
    //use the updatenotification to reuse code
    UpdateNoteNotification * notification1 = [self createUpdateNoteNotification:noteXml1];
    UpdateNoteNotification * notification2 = [self createUpdateNoteNotification:noteXml2];
    //Separated for clarity
    if (![notification1.getNoteId isEqualToString:notification2.getNoteId])
    {
        return NO;
    }
    if (![notification1.getNotePositionX isEqualToString:notification2.getNotePositionX])
    {
        return NO;
    }
    if (![notification1.getNotePositionY isEqualToString:notification2.getNotePositionY])
    {
        return NO;
    }
    if (![notification1.getNoteScale isEqualToString:notification2.getNoteScale])
    {
        return NO;
    }
    return YES;
}

-(DDXMLElement * ) getThumbnailElement:(DDXMLDocument *) document
{
    for (DDXMLElement * element in document.rootElement.children)
    {
        if ([element.name isEqualToString:FRAGMENT_NAMESPACE_DATA])
        {
            for (DDXMLElement * child in element.children)
            {
                if ([child.name isEqualToString:MINDCLOUD_COLLECTION_THUMBNAIL])
                {
                    return child;
                }
            }
        }
    }
    
    return nil;
}

-(DDXMLDocument *) createMergedDocumentWithNotes: (NSDictionary *)finalNotes
                                    andStackings: (NSDictionary *)finalStackings
                                    andThumbnail: (DDXMLElement *)thumbnailElement
{
    NSData * placeHolderData = [XoomlCollectionParser getEmptyCollectionXooml];
    NSError * err;
    DDXMLDocument * document = [[DDXMLDocument alloc] initWithData:placeHolderData options:0
                                                             error:&err];
    
    if (document == nil){
        NSLog(@"Error reading the note XML File");
        return nil;
    }
    
    DDXMLElement * fragmentNamespace = nil;
    //get the fragmentNameSpaceData element
    for (DDXMLElement * element in document.rootElement.children)
    {
        if ([element.name isEqualToString:FRAGMENT_NAMESPACE_DATA])
        {
            fragmentNamespace = element;
        }
    }
    if (!fragmentNamespace)
    {
        NSLog(@"Broken Xooml");
        return nil;
    }
    
    //add thumbnail
    if (thumbnailElement != nil)
    {
        [fragmentNamespace addChild:thumbnailElement];
    }
    
    //add stackings
    for(NSString * stackingId in finalStackings)
    {
        DDXMLElement * stackingElement = finalStackings[stackingId];
        [fragmentNamespace addChild:stackingElement];
    }
    
    //now add notes
    for(NSString * noteId in finalNotes)
    {
        DDXMLElement * noteElement = finalNotes[noteId];
        [document.rootElement addChild:noteElement];
        
    }
    
    return document;
}
@end
