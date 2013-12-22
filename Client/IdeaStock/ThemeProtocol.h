//
//  ITheme.h
//  Mindcloud
//
//  Created by Ali Fathalian on 9/27/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThemeProtocol <NSObject>

-(UIColor *) tintColor;

-(UIColor *) navigationBarButtonItemColor;

-(UIColor *) collectionBackgroundColor;

-(UIColor *) backgroundColorForAllCollectionCategory;

-(UIColor *) backgroundColorForUncategorizedCategory;

-(UIColor *) backgroundColorForSharedCategory;

-(UIColor *) backgroundColorForCustomCategory;

-(UIColor *) defaultColorForDrawing;

-(UIColor *) noisePatternForCollection;

-(UIColor *) colorForPaintControl;

-(UIColor *) tintColorForActivePaintControl;

-(UIColor *) tintColorForInactivePaintControl;

-(UIImage *) imageForPaintControl;

-(UIImage *) imageForPaintControlEraser;

-(UIImage *) iconForUndoControl;

-(UIImage *) iconForPaintControl;

-(UIImage *) iconForClearControl;

-(UIImage *) iconForEraseControl;

-(UIColor *) tintColorForActivePaintControlButton;

-(UIColor *) tintColorForInactivePaintControlButton;

-(UIImage *) imageForDeleteIcon;

-(UIColor *) tintColorForDeleteIcon;

@end
