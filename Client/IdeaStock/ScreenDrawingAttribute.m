//
//  ScreenDrawingAttribute.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/19/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ScreenDrawingAttribute.h"
#import "BoardsXoomlDefinitions.h"
#import "ExternalFileHelper.h"

//we want to make sure that drawing related IDS are always the same across all users across all xoomls
#define DRAWING_ID @"00d753a0-3952-11e3-aa6e-0800200c9a66"
#define DRAWING_TILE_ID @"1d09a640-3952-11e3-aa6e-0800200c9a66"

@interface ScreenDrawingAttribute()

@property (nonatomic, strong) NSMutableSet * touchedItems;

@end

@implementation ScreenDrawingAttribute

-(id) init
{
    self = [super init];
    if (self)
    {
        self.touchedItems = [NSMutableSet set];
    }
    return self;
}

-(void) addTouchedDrawingTileWithIndex:(NSInteger) index
{
    NSNumber * number = [NSNumber numberWithInteger:index];
    [self.touchedItems addObject:number];
}

-(XoomlNamespaceElement *) toXoomlNamespaceElement
{
    
    XoomlNamespaceElement * result = [[XoomlNamespaceElement alloc] initWithName:MINDCLOUD_DRAWING_ATTRIBUTE
                                                              andParentNamespace:MINDCLOUD_BOARDS_NAMESPACE];
    result.ID = DRAWING_ID;
    
    for(NSNumber * number in self.touchedItems)
    {
        XoomlNamespaceElement * drawingTile = [[XoomlNamespaceElement alloc] initWithName:MINDCLOUD_DRAWING_TILE_ATTRIBUTE
                                                                       andParentNamespace:MINDCLOUD_BOARDS_NAMESPACE];
        drawingTile.ID = DRAWING_TILE_ID;
        NSString * fileName = [ExternalFileHelper fileNameForDrawingWithIndex:number];
        [drawingTile addAttributeWithName:MINDCLOUD_DRAWING_FILENAME andValue:fileName];
        [drawingTile addAttributeWithName:MINDCLOUD_DRAWING_TILE_INDEX andValue:number.stringValue];
        [result addSubElement:drawingTile];
    }
    return result;
}

-(void) applyTilesInTheXoomlNamespaceElement:(XoomlNamespaceElement *) namespaceElement
{
    for(XoomlNamespaceElement * elemnt in [namespaceElement getAllSubElements])
    {
        NSString * tileIndex = [elemnt getAttributeWithName:MINDCLOUD_DRAWING_TILE_INDEX];
        NSNumber * number = [NSNumber numberWithInteger:[tileIndex integerValue]];
        [self.touchedItems addObject:number];
    }
}
@end
