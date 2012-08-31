//
//  BulletinBoardAttributes.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/30/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This is a class for holding all the attributes belonging to a bulletin board.
 * These attributes can belong to a single note or the whole bulletinBoard. 
 * 
 * This class can be thought of as a data structure that holds values for different attribute names and types. 
 * Attributes are the same if they have the same name and type. 
 *
 * The attribute types that this container can handle should be specified in initilization 
 * After initializiation its not possible to remove or rename attribute Types. 
 * Attribute names and values however can be changed. 
 *
 *Each attribute can have multiple values but it has at least one value. 
 */


@interface BulletinBoardAttributes : NSObject

/*--------------------------------------------------

                    Creation
 
 -------------------------------------------------*/

/*
 Create empty dictionaries to hold attribute names . Each dictionary is keyed on
 attribute type and is stored in attribtues.
 */
-(id) initWithAttributes: (NSArray *)attributeTypes;

/*
 Creates an attribute with Name attributeName and attributeType and stores all the values
 in the values array. 
 
 The values array is an array of NSStrings. 
 
 If the attributeType is not valid the method returns without doing anything.
 */
-(void) createAttributeWithName: (NSString *) attributeName
                forAttributeType:(NSString *) attributeType
                       andValues: (NSArray *)values;

/*
 Creates an empty attribute with attributeName and attributeType. 
 */
-(void) createAttributeWithName:(NSString *)attributeName forAttributeType:(NSString *)attributeType;
/*
 Adds the values specified in the values array ( which is an array of strings) to
 the attribtue with name and type of attributeName and attributeType 
 
 If attributeName doees not exist in the attribute lists, the method creates
 an attribtue with attributeName and puts the values in it.
 
 If attributeType is invalid the method returns without doing anything. 
 */
- (void) addValues: (NSArray *) values
       ToAttribute: (NSString *)attributeName
  forAttributeType: (NSString *) attributeType;


/*--------------------------------------------------
                       
                        Query
 
 -------------------------------------------------*/

/*
 returns all the attributes of Type attributeType as an NSArray of
 NSString containing attribute names.
 
 If attributeType is not valid the method returns nil. 
 */
-(NSDictionary *) getAllAttributeNamesForAttributeType: (NSString *) attributeType;

/*
 Returns an array of NSString containing all the values of that attribtue name 
 and type. 
 
 If the array is empty there is no value for that attribute. 
 
 If attributeNAme and attributeType are not valid, the method returns nil. 
 */
-(NSArray *) getAttributeWithName: (NSString *) attributeName
                  forAttributeType: (NSString *) attributeType;

-(NSDictionary *) getAllAttributes;
/*--------------------------------------------------
 
                        Deletion
 
 -------------------------------------------------*/

/*
 Removes all the values specified in the values array (which is an array of NSString)
 from the attribute with name attributeNAme and type attributeType. 
 
 If the attributeNAme and attributeType are not valid the method returns without
 doing anything. 
 
 If any value specified in the values array does not belong to the list of 
 values for the attribute specified with attributeName and attributeType , then
 the method ignores that value. 
 */
-(void) removeValues: (NSArray *) values
        fromAttribute: (NSString *) attributeName
     forAttributeType: (NSString *) attributeType;

/*
 removes an attribute specified by attributeName and attributeType. 
 
 Removing the attribtue will cause all of its values to be deleted. 
 
 If attributeName and attributeType are not valid. The method returns without
 doing anything
 */
-(void) removeAttribute: (NSString *) attributeName
        forAttributeType: (NSString *)AttributeType;

/*
 Removes all the occurances of the value specified by value as the value
 of any attribute with any name and type.
 */
-(void) removeAllOccurancesOfValue: (NSString *) value;

/*--------------------------------------------------
 
                    Updating
 
 -------------------------------------------------*/

/*
 Updates the name of the attribue with attributeName and the type attributeType 
 With newAttributeName
 
 If attributeName and attributeType are invalid the method returns without doing
 anything. 
 */
- (void) updateAttributeName : (NSString *) attributeName 
                       ofType: (NSString *) attributeType 
                  withNewName: (NSString *) newAttributeName;

/*
 Updates a single value of attributeName and attributeType to newValue
 
 If attributeName and attributeType are invalid the method returns without 
 doing anything. 
 */
- (void) updateAttribute: (NSString *) attributeName 
                 ofType: (NSString *) attributeType 
           withNewValue: (NSArray *) newValues;

@end
