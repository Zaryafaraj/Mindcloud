//
//  NoteRow.m
//  Lists
//
//  Created by Ali Fathalian on 4/30/13.
//  Copyright (c) 2013 MindCloud. All rights reserved.
//

#import "NoteRow.h"
#import "ThemeFactory.h"
#import "NoteTableRowLayoutManager.h"
#import "CollectionRowPaperAnimationManager.h"

@implementation NoteRow

@synthesize index = _index;
@synthesize animationManager = _animationManager;
@synthesize foregroundView = _foregroundView;

-(id) init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [self addBackgroundLayer];
        [self addActionButtons];
        [self addForegroundLayer];
        [self addTextField];
        [self addGestureRecognizers];
        self.animationManager = [[CollectionRowPaperAnimationManager alloc] init];
        self.layoutManager = [[NoteTableRowLayoutManager alloc] init];
    }
    return self;
}

-(void) addBackgroundLayer
{
    
}

-(void) addActionButtons
{
    
}

-(void) addForegroundLayer
{
    
}

-(void) addTextField
{
    
}

-(void) addGestureRecognizers
{
    
}

-(void) setText:(NSString *)text
{
    
}

-(NSString *) text
{
    return @"dummy";
}

-(void) setImage:(UIImage *)image
{
    
}

-(void) enableEditing:(BOOL)makeFirstResponder
{
    
}

-(void) disableEditing:(BOOL)resignFirstResponser
{
    
}

-(UIView<ListRow> *) prototypeSelf
{
    NoteRow * prototype = [[NoteRow alloc] init];
    prototype.frame = self.frame;
    prototype.text = self.text;
    return prototype;
}

-(void) reset
{
    
}
@end
