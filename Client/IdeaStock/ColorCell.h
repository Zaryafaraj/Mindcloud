//
//  ColorCell.h
//  Mindcloud
//
//  Created by Ali Fathalian on 10/29/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorCell : UICollectionViewCell

-(void) adjustSelectedBorderColorBaseOnBackgroundColor:(UIColor *) backgroundColor
                                       withLightColors:(NSSet *) lightColors;

@end
