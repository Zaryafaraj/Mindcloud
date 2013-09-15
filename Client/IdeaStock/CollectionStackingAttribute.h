//
//  StackingModel.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/28/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XoomlNamespaceElement.h"
@interface CollectionStackingAttribute : NSObject

@property (readonly, strong, nonatomic) NSSet * refIds;
@property NSString * scale;
@property (strong, nonatomic) NSString * ID;

-(instancetype) initWithId:(NSString *) ID
            andScale:(NSString *) scale
         andRefIds: (NSSet *) refIds;

-(void) addNotes:(NSSet *) notes;

-(void) deleteNotes:(NSSet *) notes;

+(instancetype) collectionSTackingAttributeFromNamespaceElement:(XoomlNamespaceElement *) element;

-(XoomlNamespaceElement *) toXoomlNamespaceElement;

@end
