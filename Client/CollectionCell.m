//
//  CollectionCell.m
//  Mindcloud
//
//  Created by Ali Fathalian on 10/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "CollectionCell.h"
#import <QuartzCore/QuartzCore.h>
@interface CollectionCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picImage;

@end
@implementation CollectionCell

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIView *bgView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        bgView.backgroundColor = [UIColor clearColor];
        
        bgView.layer.borderColor = [[UIColor colorWithRed:0.5 green:0.0 blue:0.9 alpha:1] CGColor];
        //[[UIColor grayColor] CGColor];
        bgView.layer.borderWidth = 5;
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
