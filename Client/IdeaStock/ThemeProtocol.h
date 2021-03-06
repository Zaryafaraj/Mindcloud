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

-(UIImage *) iconForRedoControl;

-(UIColor *) tintColorForActivePaintControlButton;

-(UIColor *) tintColorForInactivePaintControlButton;

-(UIImage *) imageForDeleteIcon;

-(UIColor *) tintColorForDeleteIcon;

-(UIImage *) imageForUndo;

-(UIImage *) imageForRedo;

-(UIColor *) colorForImageNoteTextPlaceholder;

-(UIImage *) imageForExpand;

-(UIImage *) imageForUnstack;

-(UIColor *) backgroundColorForStackController;

-(UIColor *) tintColorForIconsInStack;

-(UIImage *) imageForAddCollection;

-(UIColor *) tintColorForAddCollectionIcon;

-(UIColor *) backgroundColorFoAddCollectionCell;

-(UIColor *) backgroundColorForEmptyCollectoinCell;

-(UIColor *) colorForContainerBackground;
@end
