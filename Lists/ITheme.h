//
//  ITheme.h
//  Lists
//
//  Created by Ali Fathalian on 4/7/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ITheme <NSObject>

-(UIImage *) imageForMainScreenRowDeleteButton;
-(UIImage *) imageForMainScreenRowShareButton;
-(UIImage *) imageForMainscreenRowRenameButton;

-(UIImage *) imageCollectionScreenRowDeleteButton;

-(UIView *) stylizeMainscreenRowForeground:(UIView *) view
                                    isOpen:(BOOL) isOpen
                              withOpenBounds:(CGRect) openSize;

-(UIView *) stylizeMainScreenRowButton:(UIButton *) button;

-(UIView *) stylizeCollectionScreenRowForeground:(UIView *) view
                                    isOpen:(BOOL) isOpen
                              withOpenBounds:(CGRect) openSize;

-(UIView *) stylizeCollectionScreenRowButton:(UIButton *) button;
-(UIColor *) colorForMainScreenRowSelected;

-(CGFloat) alphaForMainScreenNavigationBar;
-(UIColor *) colorForMainScreenNavigationBar;

-(CGFloat) alphaForCollectionScreenNavigationBar;
-(UIColor *) colorForCollectionScreenNavigationBar;

-(CGFloat) spaceBetweenRowsInMainScreen;
-(CGFloat) spaceBetweenRowsInCollectionScreen;

-(UIImage *) imageForRowBackground;

@end
