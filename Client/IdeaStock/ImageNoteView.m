//
//  ImageView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 5/27/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "ImageNoteView.h"
#import "CollectionAnimationHelper.h"
#import "ThemeFactory.h"

#define INFO_BUTTON_OFFSET_X 10
#define INFO_BUTTON_OFFSET_Y 10
#define EXTENDED_EDGE_SIZE 40
#define HIDE_TEXT @"Hide Text"
#define SHOW_TEXT @"Show Text"

@interface ImageNoteView()

@property UIImageView * imageView;
@property UIView * noteView;

@end

@implementation ImageNoteView

@synthesize image = _image;
@synthesize imageView = _imageView;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self configureImageView];
    }
    return self;
}

-(void) configureImageView
{
    self.resizesToFitImage = YES;
    //find the text view
    UIView * noteView = self.subviews.firstObject;
    self.noteView = noteView;
    for (UIView * subView in self.noteView.subviews){
        if ([subView isKindOfClass:[UIImageView class]])
        {
            self.imageView = (UIImageView *) subView;
            self.text = @"";
            break;
        }
    }
}

-(void) setImage:(UIImage *)image
{
    _image = image;
    if (self.resizesToFitImage)
    {
        [self resizeNoteToMatchImageSize];
    }
    
    [self.imageView setImage:image];
    
}

-(UIImage *) image
{
    return _image;
}

-(void) resizeNoteToMatchImageSize
{
    if (self.image)
    {
        CGFloat imageWidth = self.image.size.width;
        CGFloat imageHeight = self.image.size.height;
        CGFloat newNoteHeight = (self.frame.size.width * imageHeight) / imageWidth;
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                newNoteHeight);
    }
}

-(void) setText:(NSString *)text
{
    [super setText:text];
}

-(void) setFrame:(CGRect)frame
{
    if (!CGAffineTransformIsIdentity(self.transform))
    {
        self.transform = CGAffineTransformIdentity;
    }
    
    [super setFrame:frame];
    [self adjustSubViewsForPropertyChangeInImage];
}

-(void) setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self adjustSubViewsForPropertyChangeInImage];
}

-(void) adjustSubViewsForPropertyChangeInImage
{
    if (self.imageView)
    {
        self.imageView.frame = CGRectMake(0,
                                          0,
                                          self.noteView.bounds.size.width,
                                          self.noteView.bounds.size.height);
    }
}

-(instancetype) prototype
{
    ImageNoteView * prototype = [[ImageNoteView alloc] initWithFrame:self.frame];
    prototype = [super _configurePrototype:prototype];
    UIImageView * newImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    [prototype.noteView addSubview:newImageView];
    prototype.imageView = newImageView;
    newImageView.backgroundColor = self.imageView.backgroundColor;
    newImageView.alpha = self.imageView.alpha;
    [prototype configureImageView];
    prototype._textView.text = @"";
    return prototype;
}

-(void) resizeToRect:(CGRect)rect Animate:(BOOL)animate
{
    [super resizeToRect:rect Animate:animate];
    //self.imageView.contentMode =  UIViewContentModeTopLeft;
    self.frame = super.frame;
}
-(void) resetSize
{
    [super resetSize];
    [self resizeNoteToMatchImageSize];
    
}

@end
