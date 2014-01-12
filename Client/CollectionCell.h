//
//  CollectionCell.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImage * img;
@property (nonatomic, strong) NSString * text;

@property (nonatomic, assign) BOOL placeholderForAdd;

@end
