//
//  ListRow.h
//  Lists
//
//  Created by Ali Fathalian on 4/19/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RowAnimatorProtocol.h"
#import "AwesomeMenu.h"

@protocol ListRowProtocol <NSObject>

@property (strong, nonatomic) NSString * text;
@property NSInteger index;
@property (nonatomic, strong) id<RowAnimatorProtocol> animationManager;
@property (nonatomic, strong) UIView * foregroundView;
-(UIView<ListRowProtocol> *) prototypeSelf;

-(void) enableEditing :(BOOL) makeFirstResponder;
-(void) disableEditing:(BOOL) resignFirstResponser;

@optional

@property (strong, nonatomic) UIImage * image;
@property (strong, nonatomic) AwesomeMenu * contextualMenu;
-(void) reset;

@end
