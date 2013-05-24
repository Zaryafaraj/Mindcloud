//
//  ITheme.h
//  Lists
//
//  Created by Ali Fathalian on 4/7/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThemeProtocol <NSObject>

-(CGFloat) rowWidth;
-(CGFloat) rowHeight;
-(CGFloat) subItemHeight;
-(CGFloat) contextualMenuOffset;
-(CGFloat) mainScreenLabelInsetHorizontal;
-(CGFloat) mainScreenLabelInsetVertical;
-(CGFloat) mainScreenImageInsetHorizontal;
-(CGFloat) mainScreenImageInsetVertical;
-(CGFloat) mainScreenImageWidth;

-(UIImage *) imageForMainScreenRowDeleteButton;
-(UIImage *) imageForMainScreenRowShareButton;
-(UIImage *) imageForMainscreenRowRenameButton;

-(UIImage *) imageForCollectionRowDone;

-(UIImage *) imageCollectionScreenRowDeleteButton;

-(UIImage * ) imageForCollectionRowUnDone;

-(UIView *) stylizeMainscreenRowForeground:(UIView *) view
                                    isOpen:(BOOL) isOpen
                              withOpenBounds:(CGRect) openSize;

-(UIView *) stylizeMainScreenRowButton:(UIButton *) button;

-(UIView *) stylizeCollectionScreenRowForeground:(UIView *) view
                                    isOpen:(BOOL) isOpen
                              withOpenBounds:(CGRect) openSize;

-(UIView *) stylizeCollectionScreenRowButton:(UIButton *) button;
-(UIColor *) colorForMainScreenRowSelected;

-(UIColor *) colorForTaskStateDone;
-(UIColor *) colorForTaskStateUndone;
-(UIColor *) colorForTaskStateStarred;
-(UIColor *) colorForTaskStateTimed;
-(CGFloat) alphaForMainScreenNavigationBar;
-(UIColor *) colorForMainScreenNavigationBar;
-(UIColor *) colorForMainScreenText;
-(CGFloat) alphaForCollectionScreenNavigationBar;
-(UIColor *) colorForCollectionScreenNavigationBar;

-(CGFloat) spaceBetweenRowsInMainScreen;
-(CGFloat) spaceBetweenRowsInCollectionScreen;

-(UIImage *) imageForRowBackground;

-(UIImage *) getContextualMenuItemBackground;

-(UIImage *) getContextualMenuItemBackgroundHighlighted;

-(UIImage *) getContextualMenuContentTop;

-(UIImage *) getContextualMenuContentLeft;

-(UIImage *) getContextualMenuContentRight;

-(UIImage *) getContextualMenuContentBottom;

-(UIImage *) getContextualMenuButton;

-(UIImage *) getContextualMenuButtonHighlighted;

-(UIImage *) getContextualMenuButtonContent;

-(UIImage *) getContextualMenuButtonContentHighlighted;
-(UIFont *) fontForMainScreenText;
@end
