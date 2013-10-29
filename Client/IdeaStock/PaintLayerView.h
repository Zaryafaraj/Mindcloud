//
//  CollectionViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface PaintLayerView : UIView {
@private
   // UIImage *curImage;
	
	CGMutablePathRef path;
}

-(void) parentTouchBegan:(UITouch *) touch
               withEvent:(UIEvent *) event
           andOrderIndex:(NSInteger) index;

-(void) parentTouchMoved:(UITouch *) touche
               withEvent:(UIEvent *) event
           andOrderIndex:(NSInteger) index;

-(void) parentTouchExitedTheView:(UITouch *) touch
                withCurrentPoint:(CGPoint) currentPoint
                   andOrderIndex:(NSInteger) index;

-(void) parentTouchEnteredTheView:(UITouch *) touch
               withPreviousPoint1: (CGPoint) prevPoint1
                andPreviousPoint2:(CGPoint) previPoint2
                    andOrderIndex:(NSInteger) index;

-(void) clearContent;

-(void) undoIndex:(NSInteger) index;

-(NSData *) serializeLayer;

-(void) addContentOfSerializedContainerAsBase:(NSData *) baseContainer;

-(void) addContentOfSerializedContainerAsAdded:(NSData *) addedContainer;

@property int rowIndex;
@property int colIndex;

@property CGFloat lineWidth;

-(void) cleanupContentBeingDrawn;

@property CGPoint previousPoint1;
@property CGPoint previousPoint2;
@property CGPoint currentPoint;
@property (nonatomic, retain) UIColor *lineColor;

@property BOOL eraseModeEnabled;

@property (assign, nonatomic) BOOL empty;

@end
