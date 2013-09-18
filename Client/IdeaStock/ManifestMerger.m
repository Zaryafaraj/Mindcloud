//
//  ManifestMerger.m
//  Mindcloud
//
//  Created by Ali Fathalian on 2/13/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ManifestMerger.h"
#import "XoomlFragment.h"
#import "XoomlAttributeDefinitions.h"
#import "NamespaceDefinitions.h"

@interface ManifestMerger()
@property (atomic, strong) id<XoomlProtocol> clientManifest;
@property (atomic, strong) id<XoomlProtocol> serverManifest;
@property (atomic, strong) CollectionRecorder * recorder;
@property (atomic, strong) NotificationContainer * notifications;
@end

@implementation ManifestMerger

/*! Everything is resolved based on the following rule: 
    If we are accepting something server side we should create a notification
 
    I - if there is something in the server that isn't in the client; there are two possibilities:
        1- It has never been in the client --> its a new thing and we should add it
        2- It has been in the client before but was deleted ---> the client is more uptodate and
 
    II - if there is something in the client that isn't in the server.there are two possibilities:
        1- It has been in the server but got deleted --> we should not keep it
        2- It has never been in the server and got added to the client --> we should keep it
 
    III - if something is in both of them, then there are two cases:
        1- The item has not been touched in the client --> accept the servers
        2- The item has been touched in the client. This means something got touched on the client and possibly on the server at the same time. There are two subcases:
                a- if that thing is an element that we can further break down to its components. We break it down and perform this algorithm on the smaller parts until we get a merge.
                b- That thing is atomic (it cannot be broken down or we don't record actions on its sub parts). In that case we accept the client. If server had never touched it then we are correct. If server has touched it then there is a chance of us being wrong. But since merging is distributed this will eventualy work out: On the other clients machine the merge has accepted their own element so we have two fragments that differ by that one thing. In later synch periods we discover that one thing is different and send this notification. hopefully in the client that thing has not been touched during that time so we accept the servers and we become in synch. However if the client has touched it then we repeat this process until the system goes into a balance state.
 
 
 Our atomic elements are : 
    1- A single association. We don't go lower than that to associationNamespaceElements: 
        <fragment> 
            ....
            <ASSOCIATION> ... </ASSOCIATION>
            ....
        </fragment>
 
    2- A single subElement of a subElement of a fragmentNamespace Data
        <fragment>
            <fragmentNamespaceData>
                <CustomElement>
                    <CUSTOMSUBELEMENT> .... </CUSTOMSUBELEMENT>
                </CustomElement>
            </fragmentNamespaceData>
        </fragment>
 */
-(id) initWithClientManifest:(id<XoomlProtocol>)clientManifest
           andServerManifest:(id<XoomlProtocol>)serverManifest
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

-(id<XoomlProtocol>) mergeManifests
{
    
    NSMutableDictionary * clientFragmentNamespaces = [[self.clientManifest getAllFragmentNamespaceElements] mutableCopy];
    
    NSMutableDictionary * clientAssociations = [[self.clientManifest getAllAssociations] mutableCopy];
    
    //HERE
    NSMutableDictionary * serverFragmentNamespaces = [[self.serverManifest getAllFragmentNamespaceElements] mutableCopy];
    NSMutableDictionary * serverAssociations = [[self.serverManifest getAllAssociations] mutableCopy];
    
    NSDictionary * finalFragmentNamespaces = [self mergeServerFragmentNamespaceElements:serverFragmentNamespaces
                                                    withClientFragmentNamespaceElements:clientFragmentNamespaces];
    
    NSDictionary * finalAssociations = [self mergeServerAssociations: serverAssociations
                                              withClientAssociations: clientAssociations];
    
    XoomlNamespaceElement * thumbnailElement = [self getThumbnailElement: clientFragmentNamespaces];
    XoomlFragment * finalFragment = [self createFragmentWithAssociations:finalAssociations
                                               fragmentNamespaceElements:finalFragmentNamespaces
                                                            andThumbnail:thumbnailElement];
    
    return finalFragment;
}

-(NSDictionary *) mergeServerAssociations:(NSDictionary *) serverAssociations
                   withClientAssociations:(NSDictionary *) clientAssociations
{
    
    NSSet * clientAssociationIds = [NSSet setWithArray:[clientAssociations allKeys]];
    NSSet * serverAssociationsIds = [NSSet setWithArray:[serverAssociations allKeys]];
    
    
    NSMutableSet * associationsUniqueToClient = [NSMutableSet setWithSet:clientAssociationIds];
    [associationsUniqueToClient minusSet:serverAssociationsIds];
    
    NSMutableSet * associationsUniqueToServer = [NSMutableSet setWithSet:serverAssociationsIds];
    [associationsUniqueToServer minusSet:clientAssociationIds];
    
    NSMutableSet * associationsInBoth = [NSMutableSet setWithSet:clientAssociationIds];
    [associationsInBoth intersectSet:serverAssociationsIds];
    
    NSMutableDictionary * finalAssociations = [NSMutableDictionary dictionary];
    
    //General Rule about notifications :
    // IF we are accepting something server side we should create a notification
    
    //if there is something in the server that isn't in the client; there are two possibilities:
    // 1- It has never been in the client --> its a new thing and we should add it
    // 2- It has been in the client before but was deleted ---> the client is more uptodate and
    for (NSString * associationId in associationsUniqueToServer)
    {
        //accepting server side
        if (![self.recorder hasAssociationBeenTouched:associationId])
        {
            //case 1
            finalAssociations[associationId] = serverAssociations[associationId];
            XoomlAssociation * association = finalAssociations[associationId];
            AddAssociationNotification * notification = [self createAddAssociationNotification:association];
            [self.notifications addAddAssociationNotification:notification];
        }
        //for case 2 we don't do anything since client probably has deleted it
    }
    
    //if there is something in the client that isn't in the server.there are two possibilities:
    //1- It has been in the server but got deleted --> we should not keep it
    //2- It has never been in the server and got added to the client --> we should keep it
    for(NSString * associationId in associationsUniqueToClient)
    {
        //accepting client side
        if ([self.recorder hasAssociationBeenTouched:associationId])
        {
            finalAssociations[associationId] = clientAssociations[associationId];
        }
        //accepting server side
        else
        {
            XoomlAssociation * association = clientAssociations[associationId];
            DeleteAssociationNotification * notification = [self createDeleteAssociationNotification:association];
            [self.notifications addDeleteAssociationNotification:notification];
        }
    }
    
    //if the note is in both of them, then there are two cases:
    // 1- The item has not been touched in the client --> accept the servers
    // 2- The item has been touched in the client --> accept the client
    for(NSString * associationId in associationsInBoth)
    {
        //accepting client side
        if ([self.recorder hasAssociationBeenTouched:associationId])
        {
            finalAssociations[associationId] = clientAssociations[associationId];
        }
        //accepting server side
        else
        {
            finalAssociations[associationId] = serverAssociations[associationId];
            XoomlAssociation * serverAssociation = serverAssociations[associationId];
            UpdateAssociationNotification * notification = [self createUpdateAssociationNotification:serverAssociation];
            [self.notifications addUpdateAssociationNotification:notification];
        }
    }
    return finalAssociations;
}

-(NSDictionary *) mergeServerFragmentNamespaceElements:(NSDictionary *) serverNamespaceFragments
                   withClientFragmentNamespaceElements:(NSDictionary *) clientNamespaceFragments
{
    
    NSSet * serverNamespaceIds = [NSSet setWithArray:[serverNamespaceFragments allKeys]];
    NSSet * clientNamespaceIds = [NSSet setWithArray:[clientNamespaceFragments allKeys]];
    
    NSMutableSet * namespacesUniqueToClient = [NSMutableSet setWithSet:clientNamespaceIds];
    [namespacesUniqueToClient minusSet:serverNamespaceIds];
    
    NSMutableSet * namespacesUniqueToServer = [NSMutableSet setWithSet:serverNamespaceIds];
    [namespacesUniqueToServer minusSet:clientNamespaceIds];
    
    NSMutableSet * namespacesInBoth = [NSMutableSet setWithSet:clientNamespaceIds];
    [namespacesInBoth intersectSet:serverNamespaceIds];
    
    NSMutableDictionary * finalNamespaces = [NSMutableDictionary dictionary];
    
    
    //General Rule about notifications :
    // IF we are accepting something server side we should create a notification
    
    //if there is something in the server that isn't in the client; there are two possibilities:
    // 1- It has never been in the client --> its a new thing and we should add it
    // 2- It has been in the client before but was deleted ---> the client is more uptodate and
    for (NSString * namespaceId in namespacesUniqueToServer)
    {
        //accepting server side
        if (![self.recorder hasFragmentNamespaceElementBeenTouched:namespaceId])
        {
            finalNamespaces[namespaceId] = serverNamespaceFragments[namespaceId];
            XoomlFragmentNamespaceElement * namespaceElement = finalNamespaces[namespaceId];
            AddFragmentNamespaceElementNotification * notification = [self createAddFragmentNamespaceElementNotification: namespaceElement];
            [self.notifications addAddFragmentNamespaceElementNotification:notification];
            //further more for each namespaceElement we need to send a notification for all of its subelements
            NSDictionary * allServerSubElements = [namespaceElement getAllXoomlFragmentsNamespaceSubElements];
            for(NSDictionary * subElementId in allServerSubElements)
            {
                XoomlNamespaceElement * finalSubElement = allServerSubElements[subElementId];
                AddFragmentNamespaceSubElementNotification * notification = [self createAddFragmentNamespaceSubElementNotification:finalSubElement
                                                                                                                         andParent:namespaceElement];
                [self.notifications addAddFragmentNamespaceSubElementNotification:notification];
            }
        }
        else
        {
            //dont do anything
        }
    }
    
    //if there is something in the client that isn't in the server.there are two possibilities:
    //1- It has been in the server but got deleted by someone else --> we should not keep it
    //2- It has never been in the server and got added to the client --> we should keep it
    for(NSString * namespaceId in namespacesUniqueToClient)
    {
        //accepting client side
        if ([self.recorder hasFragmentNamespaceElementBeenTouched:namespaceId])
        {
            finalNamespaces[namespaceId] = clientNamespaceFragments[namespaceId];
        }
        //accepting server side, which is deleting the client side
        else
        {
            XoomlFragmentNamespaceElement * namespaceElement = clientNamespaceFragments[namespaceId];
            DeleteFragmentNamespaceElementNotification * notification = [self createDeleteFragmentNamespaceElementNotification:namespaceElement.ID];
            [self.notifications addDeleteFragmentNamespaceElementNotification:notification];
            
           //further more for each namespaceElement we need to send a notification for all of its subelements
            NSDictionary * allClientSubElements = [namespaceElement getAllXoomlFragmentsNamespaceSubElements];
            for(NSDictionary * subElementId in allClientSubElements)
            {
                XoomlNamespaceElement * finalSubElement = allClientSubElements[subElementId];
                DeleteFragmentNamespaceSubElementNotification * notification = [self createDeleteFragmentNamespaceSubElementNotification:finalSubElement.ID
                                                                                                                            andParent:namespaceElement];
                
                [self.notifications addDeleteFragmentNamespaceSubElementNotification:notification];
            }
        }
    }
    
    //if the something is in both of them, then there are two cases:
    // 1- The item has not been touched in the client --> accept the servers
    // 2- The item has been touched in the client --> accept the client
    for(NSString * namespaceId in namespacesInBoth)
    {
        XoomlFragmentNamespaceElement * mergedElement = nil;
        XoomlFragmentNamespaceElement * serverElement = serverNamespaceFragments[namespaceId];
        XoomlFragmentNamespaceElement * clientElement = clientNamespaceFragments[namespaceId];
        
        if (serverElement == nil && clientElement == nil)
        {
            continue;
        }
        if (serverElement == nil)
        {
            mergedElement = clientElement;
        }
        else if (clientElement == nil)
        {
            mergedElement = serverElement;
        }
        else
        {
            NSDictionary * allServerSubElements = [serverElement getAllXoomlFragmentsNamespaceSubElements];
            NSDictionary * allClientSubElements = [clientElement getAllXoomlFragmentsNamespaceSubElements];
            mergedElement = [self mergeFragmentNamespaceSubElementWithId:namespaceId
                                                              fromServer:allServerSubElements
                                                              withClient:allClientSubElements
                                              andFragmenNamespaceElement:clientElement];
        }
        
        if (mergedElement != nil)
        {
            finalNamespaces[namespaceId] = mergedElement;
            
             UpdateFragmentNamespaceElementNotification * notification =[self createUpdateFragmentNamespaceElementNotification:mergedElement];
            [self.notifications addUpdateFragmentNamespaceElementNotification:notification];
        }
    }
    return finalNamespaces;
}

-(XoomlFragmentNamespaceElement *) mergeFragmentNamespaceSubElementWithId:(NSString *) ID
                                                               fromServer:(NSDictionary *) serverFragmentSubElements
                                                                   withClient:(NSDictionary *) clientFragmentSubElements andFragmenNamespaceElement:(XoomlFragmentNamespaceElement *) clientParent
{
    
    NSSet * serverSubElementIds = [NSSet setWithArray:[serverFragmentSubElements allKeys]];
    NSSet * clientSubElementIds = [NSSet setWithArray:[clientFragmentSubElements allKeys]];
    
    NSMutableSet * subElementsUniqueToClient = [NSMutableSet setWithSet:clientSubElementIds];
    [subElementsUniqueToClient minusSet:serverSubElementIds];
    
    NSMutableSet * subElementsUniqueToServer = [NSMutableSet setWithSet:serverSubElementIds];
    [subElementsUniqueToServer minusSet:clientSubElementIds];
    
    NSMutableSet * subElementsInBoth = [NSMutableSet setWithSet:clientSubElementIds];
    [subElementsInBoth intersectSet:serverSubElementIds];
    
    XoomlFragmentNamespaceElement * result = [[XoomlFragmentNamespaceElement alloc] initWithNamespaceName:clientParent.namespaceName];
    result.ID = ID;
    
    
    //General Rule about notifications :
    // IF we are accepting something server side we should create a notification
    
    //if there is something in the server that isn't in the client; there are two possibilities:
    // 1- It has never been in the client --> its a new thing and we should add it
    // 2- It has been in the client before but was deleted ---> the client is more uptodate and
    for (NSString * subElementId in subElementsUniqueToServer)
    {
        //accepting server side
        if (![self.recorder hasFragmentNamespaceSubElementBeenTouched:subElementId])
        {
            XoomlNamespaceElement * finalSubElement = serverFragmentSubElements[subElementId];
            [result addSubElement:finalSubElement];
            AddFragmentNamespaceSubElementNotification * notification = [self createAddFragmentNamespaceSubElementNotification:finalSubElement andParent:result];
            [self.notifications addAddFragmentNamespaceSubElementNotification:notification];
        }
        else
        {
            //dont do anything
        }
    }
    
    //if there is something in the client that isn't in the server.there are two possibilities:
    //1- It has been in the server but got deleted by someone else --> we should not keep it
    //2- It has never been in the server and got added to the client --> we should keep it
    for(NSString * subElementId in subElementsUniqueToClient)
    {
        //accepting client side
        if ([self.recorder hasFragmentNamespaceSubElementBeenTouched:subElementId])
        {
            XoomlNamespaceElement * finalSubelement = clientFragmentSubElements[subElementId];
            [result addSubElement:finalSubelement];
        }
        //accepting server side, which is deleting the client side
        else
        {
            XoomlNamespaceElement * clientSubElem = clientFragmentSubElements[subElementId];
            DeleteFragmentNamespaceSubElementNotification * notification = [self createDeleteFragmentNamespaceSubElementNotification:clientSubElem.ID
                                                                                                                           andParent:result];
            [self.notifications addDeleteFragmentNamespaceSubElementNotification:notification];
        }
    }
    
    //if the note is in both of them, then there are two cases:
    // 1- The item has not been touched in the client --> accept the servers
    // 2- The item has been touched in the client --> accept the client
    for(NSString * subElementId in subElementsInBoth)
    {
        //accepting client side
        if ([self.recorder hasFragmentNamespaceSubElementBeenTouched:subElementId])
        {
            XoomlNamespaceElement * mergedSubElement;
            XoomlNamespaceElement * serverSubElement = serverFragmentSubElements[subElementId];
            XoomlNamespaceElement * clientSubElement = clientFragmentSubElements[subElementId];
            
            if (serverSubElement == nil && clientSubElement == nil)
            {
                continue;
            }
            if (serverSubElement == nil)
            {
                mergedSubElement = clientSubElement;
            }
            else if (clientSubElement == nil)
            {
                mergedSubElement = serverSubElement;
            }
            else
            {
                NSDictionary * allClientLowSubElements = [clientSubElement getAllSubElements];
                NSDictionary * allServerLowSubElements = [serverSubElement getAllSubElements];
                mergedSubElement = [self mergeSubElementChildrenWithId:subElementId
                                                            fromServer:allServerLowSubElements
                                                                  with:allClientLowSubElements andClientParentNamespaceElement:clientSubElement];
                
            }
            if (mergedSubElement != nil)
            {
                [result addSubElement:mergedSubElement];
                UpdateFragmentNamespaceSubElementNotification * notification = [self createUpdateFragmentNamespaceSubElementNotification:mergedSubElement andParent:result];
                [self.notifications addUpdateFragmentNamespaceSubElementNotification:notification];
            }
        }
        
        //accepting server side
        else
        {
            XoomlNamespaceElement * serverNamespace = serverFragmentSubElements[subElementId];
            [result addSubElement:serverNamespace];
            UpdateFragmentNamespaceSubElementNotification * notification = [self createUpdateFragmentNamespaceSubElementNotification:serverNamespace andParent:result];
            [self.notifications addUpdateFragmentNamespaceSubElementNotification:notification];
        }
    }
    
    return result;
}

-(XoomlNamespaceElement *) mergeSubElementChildrenWithId:(NSString *) subElementId
                                       fromServer:(NSDictionary *) serverSubElementChildren
                                                 with:(NSDictionary *) clientSubElementChildren
                      andClientParentNamespaceElement:(XoomlNamespaceElement *) clientParent
{
    NSSet * serverChildrenIds = [NSSet setWithArray:[serverSubElementChildren allKeys]];
    NSSet * clientChildrenIds = [NSSet setWithArray:[clientSubElementChildren allKeys]];
    
    NSMutableSet * childrenUniqueToClient = [NSMutableSet setWithSet:clientChildrenIds];
    [childrenUniqueToClient minusSet:serverChildrenIds];
    
    NSMutableSet * childrenUniqueToServer = [NSMutableSet setWithSet:serverChildrenIds];
    [childrenUniqueToServer minusSet:clientChildrenIds];
    
    NSMutableSet * childrenInBoth = [NSMutableSet setWithSet:clientChildrenIds];
    [childrenInBoth intersectSet:serverChildrenIds];
    
    XoomlNamespaceElement * result = [[XoomlNamespaceElement alloc] initWithNoImmediateFragmentNamespaceParentAndName:clientParent.name];
    result.ID = subElementId;
    
    //because all of this falls under the updateXoomlFragmenNAmespaceSubelement we don't send individual notifications for those and all of them will be wrapped in an update notification sent with the result of this merge from the caller of this method.
    //General Rule about notifications :
    // IF we are accepting something server side we should create a notification
    
    //if there is something in the server that isn't in the client; there are two possibilities:
    // 1- It has never been in the client --> its a new thing and we should add it
    // 2- It has been in the client before but was deleted ---> the client is more uptodate and
    for (NSString * childId in childrenUniqueToServer)
    {
        //accepting server side
        if (![self.recorder hasFragmentSubElementChildBeenTouched:childId])
        {
            //case 1
            XoomlNamespaceElement * finalChild = serverSubElementChildren[childId];
            [result addSubElement:finalChild];
        }
        //for case 2 we don't do anything since client probably has deleted it
    }
    
    //if there is something in the client that isn't in the server.there are two possibilities:
    //1- It has been in the server but got deleted --> we should not keep it
    //2- It has never been in the server and got added to the client --> we should keep it
    for(NSString * childId in childrenUniqueToClient)
    {
        //accepting client side
        if ([self.recorder hasFragmentSubElementChildBeenTouched:childId])
        {
            XoomlNamespaceElement * finalChild  =  clientSubElementChildren[childId];
            [result addSubElement:finalChild];
        }
        //accepting server side
        else
        {
            //server side must have deleted it. do nothing since the merged result will be treated as an update
        }
    }
    
    //if the note is in both of them, then there are two cases:
    // 1- The item has not been touched in the client --> accept the servers
    // 2- The item has been touched in the client --> accept the client
    for(NSString * childId in childrenInBoth)
    {
        //accepting client side
        if ([self.recorder hasFragmentSubElementChildBeenTouched:childId])
        {
            XoomlNamespaceElement * finalChild = clientSubElementChildren[childId];
            [result addSubElement:finalChild];
        }
        //accepting server side
        else
        {
            XoomlNamespaceElement * finalChild = serverSubElementChildren[childId];
            [result addSubElement:finalChild];
        }
    }
    
    return result;
}

-(AddFragmentNamespaceElementNotification *) createAddFragmentNamespaceElementNotification:(XoomlFragmentNamespaceElement *) elem
{
    return [[AddFragmentNamespaceElementNotification alloc] initWithFragmentNamespace:elem];
}

-(UpdateFragmentNamespaceElementNotification *) createUpdateFragmentNamespaceElementNotification:(XoomlFragmentNamespaceElement *) elem
{
    return [[UpdateFragmentNamespaceElementNotification alloc] initWithFragmentNamespace:elem];
}

-(DeleteFragmentNamespaceElementNotification *) createDeleteFragmentNamespaceElementNotification:(NSString *) namespaceId
{
    return [[DeleteFragmentNamespaceElementNotification alloc] initWithFragmentNamespaceElementID:namespaceId];
}

-(AddFragmentNamespaceSubElementNotification *) createAddFragmentNamespaceSubElementNotification:(XoomlNamespaceElement *) subElement andParent:(XoomlFragmentNamespaceElement *) parent
{
    return [[AddFragmentNamespaceSubElementNotification alloc] initWithSubelement:subElement andFragmentNamespace:parent];
}

-(DeleteFragmentNamespaceSubElementNotification *) createDeleteFragmentNamespaceSubElementNotification:(NSString *) subElementId
                                                                                             andParent:(XoomlFragmentNamespaceElement *) parent
{
    return [[DeleteFragmentNamespaceSubElementNotification alloc] initWithSubelement:subElementId andFragmentNamespace:parent];
}

-(UpdateFragmentNamespaceSubElementNotification *) createUpdateFragmentNamespaceSubElementNotification:(XoomlNamespaceElement *) subElement
                                                                                             andParent:(XoomlFragmentNamespaceElement *) parent
{
    
    return [[UpdateFragmentNamespaceSubElementNotification alloc] initWithSubelement:subElement andFragmentNamespace:parent];
}

-(AddAssociationNotification *) createAddAssociationNotification:(XoomlAssociation *) association
{
    AddAssociationNotification * result = [[AddAssociationNotification alloc] initWithAssociation:association];
    return result;
}

-(DeleteAssociationNotification *) createDeleteAssociationNotification:(XoomlAssociation *) association
{
    DeleteAssociationNotification * result = [[DeleteAssociationNotification alloc] initWithAssociationId:association.ID
                                                                                                 andRefId:association.refId];
    return result;
}

-(UpdateAssociationNotification *) createUpdateAssociationNotification:(XoomlAssociation *) association
{
    
    UpdateAssociationNotification * result = [[UpdateAssociationNotification alloc] initWithAssociation:association];
    
    return result;
}


-(XoomlNamespaceElement * ) getThumbnailElement:(NSMutableDictionary *) allFragmentNamespaces
{
    for(XoomlFragmentNamespaceElement * elem in allFragmentNamespaces.allValues)
    {
        if ([elem.namespaceName isEqualToString:MINDCLOUD_XMLNS])
        {
            NSArray * allSubElements = [elem getAllXoomlFragmentsNamespaceSubElements].allValues;
            for(XoomlNamespaceElement * possibleThumbnail in allSubElements)
            {
                if ([possibleThumbnail.name isEqualToString:THUMBNAIL_ELEMENT_NAME])
                {
                    return possibleThumbnail;
                }
            }
        }
    }
    return nil;
}

-(XoomlFragment *) createFragmentWithAssociations:(NSDictionary *) associations
                        fragmentNamespaceElements:(NSDictionary *) fragmentNamespaceElements
                                     andThumbnail:(XoomlNamespaceElement *) thumbnailElement
{
    XoomlFragment * fragment = [[XoomlFragment alloc] initAsEmpty];
    
    if (fragment == nil){
        NSLog(@"ManifestMerger-Error creating empty fragment");
        return nil;
    }
    
    if (associations != nil)
    {
        for(XoomlAssociation * association in associations.allValues)
        {
            [fragment addAssociation:association];
        }
    }
    
    if (fragmentNamespaceElements != nil)
    {
        for (XoomlFragmentNamespaceElement * fragmentNamespaceElem in fragmentNamespaceElements.allValues)
        {
            [fragment setFragmentNamespaceElement:fragmentNamespaceElem];
        }
    }
    
    if (thumbnailElement != nil)
    {
        [fragment setFragmentNamespaceSubElementWithElement:thumbnailElement];
    }
    return fragment;
}
@end
