//
//  ListsCollectionRowView.h
//  Lists
//
//  Created by Ali Fathalian on 4/8/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListsCollectionRowView : UIView

@property (strong, nonatomic) UILabel * collectionLabel;
@property (strong, nonatomic) UIImageView * collectionImage;
@property NSInteger index;

-(void) reset;

@end
