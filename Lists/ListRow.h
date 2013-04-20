//
//  ListRow.h
//  Lists
//
//  Created by Ali Fathalian on 4/19/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ListRow <NSObject>

@property (strong, nonatomic) NSString * text;
@property NSInteger index;

-(UIView<ListRow> *) prototypeSelf;

@optional
@property (strong, nonatomic) UIImage * image;
-(void) reset;


@end
