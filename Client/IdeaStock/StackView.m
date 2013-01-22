//
//  StackView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 5/16/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "StackView.h"
#import "ImageView.h"

@interface StackView()

@property (strong,nonatomic) UIImage * normalImage;
@property (strong, nonatomic) UIImage * highlightedImage;
@property CGRect originalFrame;

@end

@implementation StackView

@synthesize text = _text;
@synthesize highlighted = _highlighted;
@synthesize normalImage = _normalImage;
@synthesize highlightedImage = _highlightedImage;
@synthesize ID = _ID;




-(UIImage *) normalImage{
    if (!_normalImage){
        _normalImage = [UIImage imageNamed:@"stacknoshadow.png"];
    }
    return _normalImage;
}


-(UIImage *) highlightedImage{
    if (!_highlightedImage){
        _highlightedImage = [UIImage imageNamed:@"stackSelected.png"];
    }
    return _highlightedImage;
}

-(void) setHighlighted:(BOOL) highlighted{
    
    _highlighted = highlighted;
    UIImageView * img;
    for (UIView * subView in self.subviews){
        if (highlighted){
            if ([subView isKindOfClass:[UIImageView class]]){
                [((UIImageView *) subView) setImage:self.highlightedImage];

                for (UIView * imgView in subView.subviews){
                    if ([imgView isKindOfClass:[UIImageView class]]){
                        img = (UIImageView *) imgView;
                    }
                }
                [UIView animateWithDuration:0.20 animations:^{
                    
                    [subView setTransform:CGAffineTransformMakeScale(1.3, 1.4)];
                    [img setTransform:CGAffineTransformMakeScale(0.9, 0.8)];
                }];                              
            }
        }
        else{
            if ([subView isKindOfClass:[UIImageView class]]){
                [((UIImageView *) subView) setImage:self.normalImage];
                
                for (UIView * imgView in subView.subviews){
                    if ([imgView isKindOfClass:[UIImageView class]]){
                        img = (UIImageView *) imgView;
                    }
                }

                [UIView animateWithDuration:0.20 animations:^{
                    [subView setTransform:CGAffineTransformIdentity];
                    [img setTransform:CGAffineTransformIdentity];
                }];
            }
            
        }
    }
}

-(void) setText:(NSString *) text{
    _text = text;
    for(UIView * view in self.subviews){
        if ([view isKindOfClass:[UITextView class]]){
            ((UITextView *) view).text = text;
        }
    }
}

#pragma mark - initializer

#define STARTING_POS_OFFSET_X 0.05
#define STARTING_POS_OFFSET_Y 0.2
#define TEXT_WIDHT_RATIO 0.8
#define TEXT_HEIGHT_RATIO 0.70
#define IMG_OFFSET_X_RATE 0.009
#define IMG_OFFSET_Y_RATE 0.118
#define IMG_SIZE_WIDTH_RATIO 0.89
#define IMG_SIZE_HEIGHT_RATIO 0.86
#define TEXT_FONT @"Cochin"
#define TEXT_SIZE 17.0

-(id) initWithViews: (NSMutableArray *) views
        andMainView: (NoteView *) mainView 
          withFrame:(CGRect) frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.views = views;
        
        //set image of the stack
        UIImage * image = self.normalImage;
        UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = self.bounds;
        
        //set text placeholder of the stack
        CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                      self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                      self.bounds.size.width * TEXT_WIDHT_RATIO,
                                      self.bounds.size.height * TEXT_HEIGHT_RATIO);
        UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
        textView.font = [UIFont fontWithName:TEXT_FONT size:TEXT_SIZE];
        [textView setBackgroundColor:[UIColor clearColor]];
        textView.editable = NO;
        
        [self addSubview:imageView];
        [self addSubview:textView];
        
        [self setTopViewForMainView:mainView];
        
        self.text= mainView.text;
        self.originalFrame = self.frame;
        self.mainView = mainView;
    }
    return self;    
}

-(void) setTopViewForMainView:(NoteView *) mainView
{
    if ([mainView isKindOfClass:[ImageView class]]){
        [self layImage:((ImageView *) mainView).image];
        self.mainView = mainView;
    }
    else
    {
        ImageView * topView = nil;
        for (UIView * view in self.views){
            if ([view isKindOfClass:[ImageView class]]){
                topView = (ImageView *)view;
                break;
            }
        }
        
        if (topView != nil){
            [self layImage:topView.image];
            self.mainView = topView;
        }
    }
}

#pragma mark - layout
-(void) layImage: (UIImage *) img{
    for (UIView * view in self.subviews){
        if ([view isKindOfClass:[UIImageView class]]){
            
            for(UIView * lastImage in view.subviews){
                if ([lastImage isKindOfClass:[UIImageView class]]){
                    [lastImage removeFromSuperview];
                }
            }
            UIImageView * newImage = [[UIImageView alloc] initWithImage:img];
            newImage.frame = CGRectMake(view.frame.origin.x + view.frame.size.width * IMG_OFFSET_X_RATE,
                                        view.frame.origin.y + view.frame.size.height * IMG_OFFSET_Y_RATE,
                                        view.frame.size.width * IMG_SIZE_WIDTH_RATIO,
                                        view.frame.size.height * IMG_SIZE_HEIGHT_RATIO);


            
            [view addSubview:newImage];

        }
    }
}

-(void) scale:(CGFloat) scaleFactor{
    
    if ( self.frame.size.width * scaleFactor > self.originalFrame.size.width * 3||
        self.frame.size.height * scaleFactor > self.originalFrame.size.height * 3){
        return;
    }
    if ( self.frame.size.width * scaleFactor < self.originalFrame.size.width * 0.9||
        self.frame.size.height * scaleFactor < self.originalFrame.size.height * 0.9){
        return;
    }
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y, 
                            self.frame.size.width * scaleFactor,
                            self.frame.size.height * scaleFactor);
    
    
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UIImageView class]]){
            subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y, subView.frame.size.width * scaleFactor, subView.frame.size.height * scaleFactor);
        }
        else if ([subView isKindOfClass:[UITextView class]]){
            //doing this to make the text clearer instead of resizing an existing UITextView
            NSString * oldText = ((UITextView *)subView).text;
            CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                          self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                          self.bounds.size.width * TEXT_WIDHT_RATIO, self.bounds.size.height * TEXT_HEIGHT_RATIO);
            UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
            textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
            [textView setBackgroundColor:[UIColor clearColor]];
            
            textView.text = oldText;
            
            //posisble memory leakage?
            [subView removeFromSuperview];
            
            [self addSubview:textView];
            
        }
    }
}


-(void) removeMainViewImage{
    
    if ([self.mainView isKindOfClass:[ImageView class]]){
        for (UIView * view in self.subviews){
            if ([view isKindOfClass:[UIImageView class]]){
                for (UIView * lastImg in view.subviews){
                    if ([lastImg isKindOfClass:[UIImageView class]]){
                        [lastImg removeFromSuperview];
                        return;
                    }
                }
            }
        }
    }
}
-(void) setNextMainView{
    
    [self removeMainViewImage];
    [self.views removeObject:self.mainView];
    
    ImageView * topView = nil;
    for (UIView * view in self.views){
        if ([view isKindOfClass:[ImageView class]]){
            topView = (ImageView *) view;
            break;
        }
        
    }
    if (topView != nil){
        [self layImage:topView.image];
        self.mainView = topView;
        [self setText:topView.text];
        return;
    }
    

    self.mainView = [self.views lastObject];
    [self setText:((NoteView *)[self.views lastObject]).text];
}


#pragma mark - keyboard
-(void) resignFirstResponder{
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UITextView class]]){
            if (subView.isFirstResponder){
                [subView resignFirstResponder];
            }
        }
    }
}
@end
