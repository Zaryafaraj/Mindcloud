//
//  DataModel.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthorizationDelegate.h"

/**
 * The protocol for the datamodel. Includes essential behaviors for working
 with bulletin boards and notes.
 */
@protocol MindcloudDataSource <NSObject>

/*
 Authorization
 */
-(void) authorizeUser:(NSString *) userID
withAuthenticationDelegate:(id<AuthorizationDelegate>) del;

/*! adds an associatedItem in form of a folder inside the collection with
 a xooml file.
 
 If the collection specified by does not exist, the method returns without doing anything.
 
 This method assumes that the content passed to it as NSData is verified
 and is valid.
 */
- (void) addAssociatedItemWithName: (NSString *) associatedItemName
                andFragmentContent: (NSData *) associatedItemContent
                      ToCollection: (NSString *) collectionName;


/*! adds an associatedItem in for of a folder inside the collection with a xooml file and an image inside.
 
 
 If the collection specified by does not exist, the method returns without doing anything.
 
 This method assumes that the content passed to it as NSData is verified
 and is valid.
 */
-(void) addAssociatedItemWithName: (NSString *) associatedItem
               andFragmentContent: (NSData *) content
                         andImage: (NSData *) img
                withImageFileName: (NSString *)imgName
                     toCollection: (NSString *) collectionName;

/*! Updates the collection with name with the given content as xooml file
 
 The method assumes that the collection with the name exists.
 If the collection does not exist an error should be occured.
 
 The method replaces the collection xooml with the content that is passed in
 */
-(void) updateCollectionWithName: (NSString *) collectionName
              andFragmentContent: (NSData *) content;

/*! Updates a given associatedItem with noteName with the content.
 
 The method assumes that the associatedItem and collection already exist.
 If they don't exist an error will occure.
 
 The method replaces the old associatedITem fragment content with the new one.
 */
-(void) updateAssociatedItem: (NSString *) associatedItemName
         withFragmentContent: (NSData *) conetent
                inCollection:(NSString *) collectionName;

/*! Removes an associatedItem with the name from the collection with collectionName.
 
 If the collectionName or associatedItemName are invalid the method returns without doing anything.
 
 This method is not responsible for deletion of the individual associatedItems in other xooml files
 */
- (void) removeAssociatedItem: (NSString *) associatedItemName
               FromCollection: (NSString *) collectionName;

/*! Return a NSData object with the contents of the stored collection fragment for the collectionName.
 
 In case of any error in storage or retrieval the method returns nil.
 
 The method does not gurantee the NSData returned is a valid collection fragment data.
 */
- (NSData *) getCollection: (NSString *) collectionName;

/*! Gets the associtedItem fragment contents for the passed collectionName and associatedItemName.
 
 Returns an NSData containing the fragment data for the note.
 
 If the collection and the associatedItem are not valid the method returns
 nil without doing anything.
 
 The method does not gurantee the NSData returned is a valid associatedItem xooml data.
 */
- (NSData *) getAssociatedItemForTheCollection: (NSString *) collectionName
                                      WithName: (NSString *) associatedItemName;


/*! Returns the path in the file system for the image associated with a given associatedItem in the collection.
 
 If the image does not exists returns nil
 */
- (NSString *) getImagePathForAssociatedItem: (NSString *) associatedItemId
                               andCollection: (NSString *) collectionName;


/*! Returns all the top level collections in the app folder
 */
-(NSArray *) getAllCollections;

-(void) addCollectionWithName:(NSString *) collectionName;

-(void) renameCollectionWithName:(NSString *) collectionName
                              to:(NSString *) newCollectionName;

-(void) deleteCollectionFor:(NSString *) collectionName;

/*! Categories determine the relationship between top level collections
 Returns the fragment represnting the categories object
 */
-(NSData *) getCategories;

-(void) saveCategories:(NSData *) categoriesData;

-(NSData *) getThumbnailForCollection:(NSString *) collectionName;

-(void) setThumbnail:(NSData *)thumbnailData
       forCollection:(NSString *)collectionName;

@end