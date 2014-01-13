//
//  CollectionCell.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionCellDelegate.h"


@interface CollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImage * img;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, weak) id<CollectionCellDelegate> delegate;
@property (nonatomic, assign) BOOL placeholderForAdd;
@property (nonatomic, assign) BOOL isInSelectMode;
-(void) setIsInSelectMode:(BOOL)isInSelectMode
                 animated:(BOOL) animated;

-(void) shrink:(BOOL) animated;
-(void) unshrink:(BOOL) animated;

@end
