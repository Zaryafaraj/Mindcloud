//
//  CollectionCell.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ThemeFactory.h"

@interface CollectionCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picImage;
@property (weak, nonatomic) IBOutlet UIImageView * addPlaceholderImage;

@end
@implementation CollectionCell

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        bgView.backgroundColor = [UIColor clearColor];
        self.picImage.backgroundColor = [[ThemeFactory currentTheme] collectionBackgroundColor];
        bgView.layer.borderColor = [[UIColor orangeColor] CGColor];
        bgView.layer.borderWidth = 3;
        self.selectedBackgroundView = bgView;
    }
    return self;
}
-(void) setText:(NSString *)text
{
    _text = text;
    _titleLabel.text = text;
}

-(void) setImg:(UIImage *)img
{
    _img = img;
    _picImage.image = img;
    
    self.picImage.backgroundColor = [[ThemeFactory currentTheme] collectionBackgroundColor];
}


-(void) setPlaceholderForAdd:(BOOL)placeholderForAdd
{
    _placeholderForAdd = placeholderForAdd;
    if (placeholderForAdd)
    {
        self.addPlaceholderImage.hidden = NO;
        self.picImage.image = nil;
        self.img = nil;
        self.picImage.hidden = YES;
    }
    else
    {
        self.addPlaceholderImage.hidden = YES;
        self.picImage.hidden = NO;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
