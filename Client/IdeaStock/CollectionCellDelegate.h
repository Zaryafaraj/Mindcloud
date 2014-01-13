//
//  CollectionCellDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/12/14.
//  Copyright (c) 2014 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CollectionCellDelegate <NSObject>

-(void) cellLongPressed:(UICollectionViewCell *) cell;

@end
