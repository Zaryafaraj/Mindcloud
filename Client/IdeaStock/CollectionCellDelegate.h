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

-(void) deletePressed:(UICollectionViewCell *) cell;

-(void) sharePressed:(UICollectionViewCell *) cell
          fromButton:(UIButton *) button;

-(void) categorizedPressed:(UICollectionViewCell *) cell
                fromButton:(UIButton *)button;

-(void) renamePressed:(UICollectionViewCell *) cell
          fromOldName:(NSString *) oldName;

-(void) becameFirstResponder:(UICollectionViewCell *) cell;

@end
