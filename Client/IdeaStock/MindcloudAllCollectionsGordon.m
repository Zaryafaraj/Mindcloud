//
//  MindcloudAllCollectionsGordon.m
//  Mindcloud
//
//  Created by Ali Fathalian on 8/25/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "MindcloudAllCollectionsGordon.h"
#import "SharingAwareObject.h"
#import "AllCollectionsSharingAdapter.h"
#import "MindcloudDataSource.h"
#import "CachedMindCloudDataSource.h"
#import "EventTypes.h"
#import "XoomlFragment.h"
#import "NamespaceDefinitions.h"
#import "XoomlAttributeDefinitions.h"

#define SYNCHRONIZATION_PERIOD 10

@interface MindcloudAllCollectionsGordon()

@property (strong, nonatomic) id<MindcloudDataSource, SharingAwareObject> dataSource;
@property (strong, nonatomic) AllCollectionsSharingAdapter * sharingAdapter;
@property (weak, nonatomic) id<MindcloudAllCollectionsGordonDelegate> delegate;
@property BOOL shouldSaveCategories;

@property (strong, nonatomic) XoomlFragment * categoriesFragment;
@property (strong, nonatomic) NSMutableSet * allCollectionNames;

@end

@implementation MindcloudAllCollectionsGordon


-(id) initWithDelegate:(id<MindcloudAllCollectionsGordonDelegate>) delegate
{
    self = [super init];
    if (self)
    {
        self.shouldSaveCategories = NO;
        self.dataSource = [[CachedMindCloudDataSource alloc] init];
        self.sharingAdapter = [[AllCollectionsSharingAdapter alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(collectionShared:)
                                                     name:COLLECTION_SHARED
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(allCollectionsReceived:)
                                                     name: ALL_COLLECTIONS_LIST_DOWNLOADED_EVENT
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(categoriesReceived:)
                                                     name: CATEGORIES_RECEIVED_EVENT
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(thumbnailReceived:)
                                                     name: COLLECTION_IMAGE_RECEIVED_EVENT
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(subscribedToCollection:)
                                                     name:SUBSCRIBED_TO_COLLECTION
                                                   object:nil];
        
        
        NSData * categoriesData = [self.dataSource getCategories];
        
        //no offline daata
        if (categoriesData == nil)
        {
            self.categoriesFragment = [[XoomlFragment alloc] initAsEmpty];
        }
        //use the offline data for now until you get the categoriesReceived notification
        else
        {
            NSString * fragmentXML = [[NSString alloc] initWithData:categoriesData encoding:NSUTF8StringEncoding];
            self.categoriesFragment = [[XoomlFragment alloc] initWithXMLString:fragmentXML];
        }
        
        NSArray * allCollections = [self.dataSource getAllCollections];
        if (allCollections == nil)
        {
            self.allCollectionNames = [NSMutableSet set];
        }
        else
        {
            self.allCollectionNames = [NSMutableSet setWithArray:allCollections];
        }
    }
    return self;
}


-(id<MindcloudAllCollectionsGordonDelegate>) delegate
{
    if (_delegate != nil)
    {
        id<MindcloudAllCollectionsGordonDelegate> tempDel = _delegate;
        return tempDel;
    }
    return nil;
}

-(void) addCollectionWithName:(NSString *) collectionName
{
    
    [self.dataSource addCollectionWithName:collectionName];
    [self.allCollectionNames addObject:collectionName];
    XoomlAssociation * association = [[XoomlAssociation alloc] initWithAssociatedItem:collectionName];
    [self.categoriesFragment addAssociation:association];
    [self saveCategories];
}

-(void) deleteCollectionWithName:(NSString *) collectionName
{
    CachedMindCloudDataSource * collectionDataSource = [CachedMindCloudDataSource getInstance:collectionName];
    [collectionDataSource deleteCollectionFor:collectionName];
    [self.allCollectionNames removeObject:collectionName];
    [self.categoriesFragment removeAllAssociationsWithAssociatedFragmentName:collectionName];
    [self saveCategories];
}

-(void) renameCollectionWithName:(NSString *) collectionName
                              to:(NSString *) newCollectionName
{
    [self.dataSource renameCollectionWithName:collectionName to:newCollectionName];
    [self.allCollectionNames removeObject:collectionName];
    [self.allCollectionNames addObject:newCollectionName];
    [self.categoriesFragment removeAllAssociationsWithAssociatedFragmentName:collectionName];
    XoomlAssociation * association = [[XoomlAssociation alloc] initWithAssociatedItem:newCollectionName];
    [self.categoriesFragment addAssociation:association];
    [self saveCategories];
}

-(NSData *) getThumbnailForCollection:(NSString *) collectionName
{
    //these are collection specific data sources
    CachedMindCloudDataSource * dataSource = [CachedMindCloudDataSource getInstance:collectionName];
    NSData * imgData = [dataSource getThumbnailForCollection:collectionName];
    return imgData;
}

-(NSArray *) getAllCollections
{
    if (self.allCollectionNames == nil) return @[];
    return self.allCollectionNames.allObjects;
}

-(NSDictionary *) getAllCategoriesMappings
{
    return [self createCategoriesMaping];
}

-(void) addEmptyCategory:(NSString *) categoryName
{
    
    XoomlNamespaceElement * categorySubElement = [[XoomlNamespaceElement alloc] initWithName:CATEGORY_SUB_ELEMENT_NAME
                                                                          andParentNamespace:MINDCLOUD_XMLNS];
    [categorySubElement addAttributeWithName:CATEGORY_NAME_ATTRIBUTE andValue:categoryName];
    [self.categoriesFragment addFragmentNamespaceSubElement:categorySubElement];
    [self saveCategories];
}

-(void) addCategory:(NSString *) categoryName withCollections:(NSArray *) collectionNames
{
    XoomlNamespaceElement * categorySubElement = [[XoomlNamespaceElement alloc] initWithName:CATEGORY_SUB_ELEMENT_NAME
                                                                          andParentNamespace:MINDCLOUD_XMLNS];
    [categorySubElement addAttributeWithName:CATEGORY_NAME_ATTRIBUTE andValue:categoryName];
    
    
    //TODO Make sure this loop is performant enough for users with large number of collections
    NSDictionary * collectionNameToAsscoiationIdMap = [self getCollectionNameToAssociationIdMap];
    
    for(NSString * collectionName in collectionNames)
    {
        NSString * associationId = collectionNameToAsscoiationIdMap[collectionName];
        if (associationId)
        {
            XoomlNamespaceElement * categoryRefElement = [[XoomlNamespaceElement alloc] initWithNoImmediateFragmentNamespaceParentAndName:REFERENCE_ELEMENT];
            [categoryRefElement addAttributeWithName:REF_ID andValue:associationId];
            [categorySubElement addSubElement:categoryRefElement];
        }
    }
    
    [self.categoriesFragment addFragmentNamespaceSubElement:categorySubElement];
    [self saveCategories];
}

-(void) addToCategory:(NSString *) categoryName collectionsWithNames:(NSArray *) collectionNAmes
{
    NSArray * allCategories = [self.categoriesFragment getFragmentNamespaceSubElementsWithName:CATEGORY_SUB_ELEMENT_NAME
                                                                               forNamespaceURL:MINDCLOUD_XMLNS];
    
    NSDictionary * collectionNameToAsscoiationIdMap = [self getCollectionNameToAssociationIdMap];
    
    for(XoomlNamespaceElement * category in allCategories)
    {
        NSString * searchCategoryName = [category getAttributeWithName:CATEGORY_NAME_ATTRIBUTE];
        if (searchCategoryName != nil && [searchCategoryName isEqualToString:categoryName])
        {
            for(NSString * collectionName in collectionNAmes)
            {
                NSString * associationId = collectionNameToAsscoiationIdMap[collectionName];
                if (associationId)
                {
                    XoomlNamespaceElement * categoryChild = [[XoomlNamespaceElement alloc] initWithNoImmediateFragmentNamespaceParentAndName:REFERENCE_ELEMENT];
                    [categoryChild addAttributeWithName:REF_ID andValue:associationId];
                    [category addSubElement:categoryChild];
                    [self.categoriesFragment setFragmentNamespaceSubElementWithElement:category];
                    [self saveCategories];
                    return;
                }
            }
        }
    }
}

-(void) removeCategory:(NSString *) categoryName
{
    
    NSArray * allCategories = [self.categoriesFragment getFragmentNamespaceSubElementsWithName:CATEGORY_SUB_ELEMENT_NAME
                                                                               forNamespaceURL:MINDCLOUD_XMLNS];
    
    for(XoomlNamespaceElement * category in allCategories)
    {
        
        NSString * searchCategoryName = [category getAttributeWithName:CATEGORY_NAME_ATTRIBUTE];
        if (searchCategoryName != nil && [searchCategoryName isEqualToString:categoryName])
        {
            [self.categoriesFragment removeFragmentNamespaceSubElementWithId:category.ID
                                                                     andName:CATEGORY_SUB_ELEMENT_NAME
                                                            fromNamespaceURL:MINDCLOUD_XMLNS];
            
            [self saveCategories];
            return;
        }
    }
}

-(void) removeFromCategory:(NSString *) categoryName collectionsWithName:(NSArray *) collectionNames
{
    NSArray * allCategories = [self.categoriesFragment getFragmentNamespaceSubElementsWithName:CATEGORY_SUB_ELEMENT_NAME
                                                                               forNamespaceURL:MINDCLOUD_XMLNS];
    
    
    NSMutableSet * refIdsToDelete = [NSMutableSet set];
    NSDictionary * allAssociations = [self.categoriesFragment getAllAssociations];
    NSSet * collectionNamesSet = [NSSet setWithArray:collectionNames];
    for (XoomlAssociation * association in allAssociations)
    {
        NSString * collectionName = association.associatedXooMLFragment;
        if ([collectionNamesSet containsObject:collectionName])
        {
            [refIdsToDelete addObject:association.ID];
        }
    }
    
    for(XoomlNamespaceElement * category in allCategories)
    {
        NSString * searchCategoryName = [category getAttributeWithName:CATEGORY_NAME_ATTRIBUTE];
        if (searchCategoryName != nil && [searchCategoryName isEqualToString:categoryName])
        {
            NSDictionary * categoryRefElems = [category getAllSubElements];
            
            for(NSString * categoryRefId in categoryRefElems)
            {
                XoomlNamespaceElement * categoryRefElem = categoryRefElems[categoryRefId];
                NSString * categoryRefId = [categoryRefElem getAttributeWithName:REF_ID];
                if ([refIdsToDelete containsObject:categoryRefId])
                {
                    [category removeSubElement:categoryRefElem.ID];
                }
                
            }
            [self.categoriesFragment setFragmentNamespaceSubElementWithElement:category];
            [self saveCategories];
            return;
        }
    }
    
}

-(void) moveCollection:(NSString *) collectionToMove
       fromOldCategory:(NSString *) oldCategory
         toNewCategory:(NSString *) newCategory
{
    
    NSArray * allCategories = [self.categoriesFragment getFragmentNamespaceSubElementsWithName:CATEGORY_SUB_ELEMENT_NAME
                                                                               forNamespaceURL:MINDCLOUD_XMLNS];
    
    
    NSDictionary * allAssociations = [self.categoriesFragment getAllAssociations];
    NSString * refIdToDelete;
    for (XoomlAssociation * association in allAssociations)
    {
        NSString * collectionName = association.associatedXooMLFragment;
        if ([collectionName isEqualToString:collectionToMove])
        {
            refIdToDelete = association.ID;
            break;
        }
    }
    
    if (refIdToDelete == nil) return;
    
    XoomlNamespaceElement * oldCategoryElem;
    XoomlNamespaceElement * newCategoryElem;
    for(XoomlNamespaceElement * category in allCategories)
    {
        NSString * searchCategoryName = [category getAttributeWithName:CATEGORY_NAME_ATTRIBUTE];
        if (searchCategoryName != nil && [searchCategoryName isEqualToString:oldCategory])
        {
            oldCategoryElem = category;
        }
        if (searchCategoryName != nil && [searchCategoryName isEqualToString:newCategory])
        {
            newCategoryElem = category;
        }
    }
    
    if (oldCategoryElem == nil || newCategoryElem == nil) return;
    
    NSDictionary * categoryRefElems = [oldCategoryElem getAllSubElements];
    
    for(NSString * categoryRefId in categoryRefElems)
    {
        XoomlNamespaceElement * categoryRefElem = categoryRefElems[categoryRefId];
        NSString * categoryRefId = [categoryRefElem getAttributeWithName:REF_ID];
        if ([refIdToDelete isEqualToString:categoryRefId])
        {
            [oldCategoryElem removeSubElement:categoryRefElem.ID];
            [newCategoryElem addSubElement:categoryRefElem];
            [self.categoriesFragment setFragmentNamespaceSubElementWithElement:oldCategoryElem];
            [self.categoriesFragment setFragmentNamespaceSubElementWithElement:newCategoryElem];
            [self saveCategories];
            break;
        }
    }
    
    return;
}
-(void) renameCategory:(NSString *) categoryName
             toNewName:(NSString *) newCategoryName
{
    
    NSArray * allCategories = [self.categoriesFragment getFragmentNamespaceSubElementsWithName:CATEGORY_SUB_ELEMENT_NAME
                                                                               forNamespaceURL:MINDCLOUD_XMLNS];
    
    for(XoomlNamespaceElement * category in allCategories)
    {
        NSString * searchCategoryName = [category getAttributeWithName:CATEGORY_NAME_ATTRIBUTE];
        if (searchCategoryName != nil && [searchCategoryName isEqualToString:categoryName])
        {
            [category removeAttributeNamed:CATEGORY_NAME_ATTRIBUTE];
            [category addAttributeWithName:CATEGORY_NAME_ATTRIBUTE andValue:newCategoryName];
            [self saveCategories];
            return;
        }
    }
}

-(void) applyCategories:(NSDictionary *) mapping
{
    
    //first remove everything
    [self.categoriesFragment removeFragmentNamespaceSubElementWithName:CATEGORY_SUB_ELEMENT_NAME
                                                       forNamespaceURL:MINDCLOUD_XMLNS];
    
    //For performance reasons we update the fragmentNamespaceElement instead of updating individual sub category subelements
    NSDictionary * allFragmentNamespaceElemts =[self.categoriesFragment getAllFragmentNamespaceElements];
    
    for(XoomlFragmentNamespaceElement * fragmentNamespaceElem in allFragmentNamespaceElemts)
    {
        //since we should only have one namespace element for mindcloud stop at the first one and return after
        //operation is finished
        if([fragmentNamespaceElem.namespaceURL isEqualToString:MINDCLOUD_XMLNS])
        {
            //if its our namespace add the categories here
            NSDictionary * collectionNameToAsscoiationIdMap = [self getCollectionNameToAssociationIdMap];
            
            for(NSString * categoryName in mapping)
            {
                XoomlNamespaceElement * categoryElem = [[XoomlNamespaceElement alloc] initWithName:CATEGORY_SUB_ELEMENT_NAME andParentNamespace:MINDCLOUD_XMLNS];
                NSArray * collectionsInCategory = mapping[categoryName];
                for(NSString * collectionName in collectionsInCategory)
                {
                    NSString * refId = collectionNameToAsscoiationIdMap[collectionName];
                    if (refId)
                    {
                        XoomlNamespaceElement * categoryChild = [[XoomlNamespaceElement alloc] initWithNoImmediateFragmentNamespaceParentAndName:REFERENCE_ELEMENT];
                        [categoryChild addAttributeWithName:CATEGORY_NAME_ATTRIBUTE andValue:refId];
                        [categoryElem addSubElement:categoryChild];
                    }
                }
                [fragmentNamespaceElem addSubElement:categoryElem];
            }
            //now do the update
            [self.categoriesFragment setFragmentNamespaceElementWithId:fragmentNamespaceElem.ID
                                                           withElement:fragmentNamespaceElem];
            [self saveCategories];
            return;
        }
    }
}

-(NSDictionary *) getCollectionNameToAssociationIdMap
{
    NSMutableDictionary * collectionNameToAsscoiationIdMap = [NSMutableDictionary dictionary];
    
    NSDictionary * allAssociations = [self.categoriesFragment getAllAssociations];
    
    for (XoomlAssociation * association in allAssociations)
    {
        NSString * collectionName = association.associatedXooMLFragment;
        collectionNameToAsscoiationIdMap[collectionName] = association.ID;
    }
    return collectionNameToAsscoiationIdMap;
}

-(void) shareCollection:(NSString *) collectionName
{
    [self.sharingAdapter shareCollection:collectionName];
}

-(void) unshareCollection:(NSString *) collectionName
{
    [self.sharingAdapter unshareCollection:collectionName];
    [self.dataSource collectionIsNotShared:collectionName];
}

-(void) subscribeToCollectionWithSecret:(NSString *) secret
{
    [self.sharingAdapter subscriberToCollection:secret];
}

#pragma mark - notifications

-(void) collectionShared:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    NSString * sharingSecret = result[@"sharingSecret"];
    if (collectionName)
    {
        
        id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
        if (tempDel)
        {
            [tempDel collectionGotShared:collectionName
                              withSecret:sharingSecret];
            
        }
        self.shouldSaveCategories = YES;
    }
}

-(void) subscribedToCollection:(NSNotification *) notification
{
    NSDictionary * result = notification.userInfo[@"result"];
    NSString * collectionName = result[@"collectionName"];
    id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        if (collectionName)
        {
            [tempDel subscribedToSharingSpaceForCollection:collectionName];
            
        }
        else
        {
            [tempDel failedToSubscribeToSharingSpace];
        }
    }
}
-(void) allCollectionsReceived:(NSNotification *) notification
{
    NSArray* allCollections = notification.userInfo[@"result"];
    
    self.allCollectionNames = [NSMutableSet setWithArray:allCollections];
    
    [self consolidateCategoriesAndCollections];
    
    id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel collectionsLoaded:allCollections];
        
    }
}

-(void) categoriesReceived:(NSNotification *) notification
{
    
    NSData * categoriesData = notification.userInfo[@"result"];
    
    if (categoriesData != nil)
    {
        NSString * fragmentXML = [[NSString alloc] initWithData:categoriesData encoding:NSUTF8StringEncoding];
        self.categoriesFragment = [[XoomlFragment alloc] initWithXMLString:fragmentXML];
    }
    else
    {
        self.categoriesFragment = [[XoomlFragment alloc] initAsEmpty];
    }
    
    [self consolidateCategoriesAndCollections];
    
    id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        
        NSDictionary * result = [self createCategoriesMaping];
        [tempDel categoriesLoaded:result];
    }
}

/*! Makes sure that there is an association in categories XML to each collection so that they are in sync.
 Doesn't destory existing associations
 */
-(void) consolidateCategoriesAndCollections
{
    
    //All collections/categories  haven't been received yet, return and wait for consolodiation to happen when they are received
    if (self.allCollectionNames == nil || [self.allCollectionNames count] == 0|| self.categoriesFragment == nil)
    {
        return;
    }
    
    NSDictionary * allAssociations = [self.categoriesFragment getAllAssociations];
    NSMutableSet * allCollectionNamesInCategoriesFragment = [NSMutableSet set];
    for(XoomlAssociation * association in allAssociations)
    {
        NSString * collectionName = association.associatedXooMLFragment;
        [allCollectionNamesInCategoriesFragment addObject:collectionName];
    }
    
    
    NSMutableSet * collectionsNotInCategoriesFragment = [NSMutableSet setWithSet:self.allCollectionNames];
    [collectionsNotInCategoriesFragment minusSet:allCollectionNamesInCategoriesFragment];
    
    for(NSString * collectionName in collectionsNotInCategoriesFragment)
    {
        XoomlAssociation * association = [[XoomlAssociation alloc] initWithAssociatedItem:collectionName];
        [self.categoriesFragment addAssociation:association];
    }
    
}

/*! Returns a dictionary of arrays. Each key is a categoryName and each value is an array of collectionNames
 in that category */
-(NSDictionary *) createCategoriesMaping
{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    if (self.categoriesFragment == nil)
    {
        return dictionary;
    }
    
    NSDictionary * allAssociatoins = [self.categoriesFragment getAllAssociations];
    NSArray * allSubElements = [self.categoriesFragment getFragmentNamespaceSubElementsWithName:CATEGORY_SUB_ELEMENT_NAME
                                                                                forNamespaceURL:MINDCLOUD_XMLNS];
    for (XoomlNamespaceElement * subElement in allSubElements)
    {
        NSString * categoryName = [subElement getAttributeWithName:CATEGORY_NAME_ATTRIBUTE];
        NSDictionary * allSubElementChildren = [subElement getAllSubElements];
        if (allSubElementChildren == nil)
        {
            dictionary[categoryName] = @[];
        }
        else
        {
            NSMutableArray * collectionNamesInCategory = [NSMutableArray array];
            for(XoomlNamespaceElement * child in allSubElementChildren)
            {
                NSString * refId = [child getAttributeWithName:REF_ID];
                if (refId)
                {
                    XoomlAssociation * referencedAssociation = allAssociatoins[refId];
                    if (referencedAssociation)
                    {
                        NSString * collectionName = referencedAssociation.associatedXooMLFragment;
                        if (collectionName)
                        {
                            [collectionNamesInCategory addObject:collectionName];
                        }
                    }
                }
            }
            dictionary[categoryName] = collectionNamesInCategory;
        }
    }
    return dictionary;
}

-(void) thumbnailReceived:(NSNotification *) notification
{
    
    NSDictionary * dict = notification.userInfo[@"result"];
    NSString * collectionName = dict[@"collectionName"];
    NSData * imgData = dict[@"data"];
    //if there is no image on the server use our default image
    if (!imgData)
    {
        UIImage * defaultImage = [UIImage imageNamed: @"felt-red-ipad-background.jpg"];
        imgData = UIImageJPEGRepresentation(defaultImage, 1);
    }
    
    id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        [tempDel thumbnailLoadedForCollection:collectionName andData:imgData];
        
    }
    
}

-(void) saveCategories
{
    id<MindcloudAllCollectionsGordonDelegate> tempDel = self.delegate;
    if (tempDel)
    {
        NSString * xmlString = [self.categoriesFragment toXmlString];
        NSData * categoriesData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
        [self.dataSource saveCategories:categoriesData];
        self.shouldSaveCategories = NO;
    }
}

-(void) refresh
{
    
    NSData * categoriesData = [self.dataSource getCategories];
    
    //no offline daata
    if (categoriesData == nil)
    {
        self.categoriesFragment = [[XoomlFragment alloc] initAsEmpty];
    }
    //use the offline data for now until you get the categoriesReceived notification
    else
    {
        NSString * fragmentXML = [[NSString alloc] initWithData:categoriesData encoding:NSUTF8StringEncoding];
        self.categoriesFragment = [[XoomlFragment alloc] initWithXMLString:fragmentXML];
    }
    
    NSArray * allCollections = [self.dataSource getAllCollections];
    if (allCollections == nil)
    {
        self.allCollectionNames = [NSMutableSet set];
    }
    else
    {
        self.allCollectionNames = [NSMutableSet setWithArray:allCollections];
    }
}

@end
