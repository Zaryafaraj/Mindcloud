//
//  StackView.m
//  IdeaStock
//
//  Created by Ali Fathalian on 5/16/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "StackView.h"
#import "ImageView.h"
#import "CollectionAnimationHelper.h"

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
@synthesize scaleOffset = _scaleOffset;


-(CGFloat)scaleOffset
{
    if (_scaleOffset <= 0)
    {
        _scaleOffset = 1;
    }
    return _scaleOffset;
}

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

#define IMG_TRANSLATION_RATIO_X -0.035
#define IMG_TRANSLATION_RATIO_Y 0.059
-(void) setHighlighted:(BOOL) highlighted{
    
    _highlighted = highlighted;
    UIImageView * img;
    //Make sure that when the stack view is highlighted all the underlying views like image and text get
    //resized too
    
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
                    [subView setTransform:CGAffineTransformMakeScale(1.25, 1.35)];
                    CGFloat imgWidth = img.frame.size.width * IMG_TRANSLATION_RATIO_X;
                    CGFloat imgHeight = img.frame.size.height * IMG_TRANSLATION_RATIO_Y;
                    NSLog(@"%f - %f ", imgWidth, imgHeight);
                    [img setTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(0.91, 0.82), imgWidth, imgHeight)];
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

#define STARTING_POS_OFFSET_X 0.11
#define STARTING_POS_OFFSET_Y 0.14
#define TEXT_WIDHT_RATIO 0.8
#define TEXT_HEIGHT_RATIO 0.70
#define IMG_OFFSET_X_RATE 0.0701
#define IMG_OFFSET_Y_RATE 0.093
#define IMG_SIZE_WIDTH_RATIO 0.852
#define IMG_SIZE_HEIGHT_RATIO 0.810
#define TEXT_FONT @"Cochin"
#define TEXT_SIZE 17.0

//what we have is a main stack view, a layer of image view under it which is the image of the stack, and another layer
//underneath it which is the image that stands on top of the stack image
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
    }
    return self;
}

-(void) setTopViewForMainView:(NoteView *) mainView
{
    //if the stack has an image note that always has the priority to be
    //the top view over the mainView that was passed as the designated view to the stack
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
        else
        {
            self.mainView = mainView;
        }
    }
}

#pragma mark - addition
-(void) addNoteView:(NoteView *) note
{
    [note removeFromSuperview];
    [self.views addObject:note];
    //force the item to become the mainView
    [self forceSetNoteAsMainView:note];
}

-(void) forceSetNoteAsMainView:(NoteView *)note
{
    if ([note isKindOfClass:[ImageView class]])
    {
        [self layImage:((ImageView *) note).image];
        self.mainView = note;
    }
    else
    {
        self.mainView = note;
    }
}

#pragma mark - deletion
-(void) removeNoteView:(NoteView *)note
{
    if ([self.views containsObject:note])
    {
        [self.views removeObject:note];
        [note removeFromSuperview];
        [self setNextMainViewWithNoteToRemove:note];
        if([self.views count] == 0)
        {
            //manifest update will take care of this
            //  [self.delegate stackViewIsEmpty:self];
        }
    }
}

#pragma mark - query
-(NSSet *) getAllNoteIds
{
    NSMutableSet * result = [NSMutableSet set];
    for (NoteView * noteView in self.views)
    {
        [result addObject:noteView.ID];
    }
    return result;
}

#pragma mark - layout
//lays the img on top of the stack view as its image
-(void) layImage: (UIImage *) img{
    
    //remove the last image view that was on top
    for (UIView * view in self.subviews){
        if ([view isKindOfClass:[UIImageView class]]){
            for(UIView * lastImage in view.subviews){
                if ([lastImage isKindOfClass:[UIImageView class]]){
                    [lastImage removeFromSuperview];
                }
            }
            //now add the new image
            UIImageView * newImage = [[UIImageView alloc] initWithImage:img];
            newImage.frame = CGRectMake(view.frame.origin.x + view.frame.size.width * IMG_OFFSET_X_RATE,
                                        view.frame.origin.y + view.frame.size.height * IMG_OFFSET_Y_RATE,
                                        view.frame.size.width * IMG_SIZE_WIDTH_RATIO,
                                        view.frame.size.height * IMG_SIZE_HEIGHT_RATIO);
            
            [view addSubview:newImage];
            break;
        }
    }
}

-(void) scaleWithScaleOffset:(CGFloat)scaleOffset animated:(BOOL)animated
{
    self.scaleOffset = scaleOffset;
    
    CGRect newFrame = CGRectMake(self.frame.origin.x,
                                 self.frame.origin.y,
                                 self.originalFrame.size.width * scaleOffset,
                                 self.originalFrame.size.height * scaleOffset);
    
    self.frame = newFrame;
    
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UIImageView class]]){
            CGRect subViewFrame = self.bounds;
            
            if (animated)
            {
                [CollectionAnimationHelper animateChangeFrame:subView withNewFrame:subViewFrame];
            }
            else
            {
                subView.frame = subViewFrame;
            }
            //if we have an image on top of the stack that will be the subview of this image view which is the stack image
            for(UIView * stackTop in subView.subviews)
            {
                if ([stackTop isKindOfClass:[UIImageView class]])
                {
                    CGRect frame = CGRectMake(subView.frame.origin.x + subView.frame.size.width * IMG_OFFSET_X_RATE,
                                              subView.frame.origin.y + subView.frame.size.height * IMG_OFFSET_Y_RATE,
                                              subView.frame.size.width * IMG_SIZE_WIDTH_RATIO,
                                              subView.frame.size.height * IMG_SIZE_HEIGHT_RATIO);
                    
                    if (animated)
                    {
                        [CollectionAnimationHelper animateChangeFrame:stackTop
                                                         withNewFrame:frame];
                    }
                    else
                    {
                        stackTop.frame = frame;
                        
                    }
                }
                
            }
            
        }
        else if ([subView isKindOfClass:[UITextView class]]){
            //doing this to make the text clearer instead of resizing an existing UITextView
            
            CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                          self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                          self.bounds.size.width * TEXT_WIDHT_RATIO,
                                          self.bounds.size.height * TEXT_HEIGHT_RATIO);
            [CollectionAnimationHelper animateChangeFrame:subView withNewFrame:textFrame];
        }
    }
}
-(void) scale:(CGFloat) scaleFactor animated:(BOOL)animated{
    
    if ( self.frame.size.width * scaleFactor > self.originalFrame.size.width * 2||
        self.frame.size.height * scaleFactor > self.originalFrame.size.height * 2){
        return;
    }
    if ( self.frame.size.width * scaleFactor < self.originalFrame.size.width * 0.9||
        self.frame.size.height * scaleFactor < self.originalFrame.size.height * 0.9){
        return;
    }
    
    self.scaleOffset *= scaleFactor;
    CGRect frame = CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width * scaleFactor,
                              self.frame.size.height * scaleFactor);
    
    self.frame = frame;
    
    for (UIView * subView in self.subviews){
        if ([subView isKindOfClass:[UIImageView class]]){
            CGRect subViewFrame = CGRectMake(subView.frame.origin.x,
                                             subView.frame.origin.y,
                                             subView.frame.size.width * scaleFactor,
                                             subView.frame.size.height * scaleFactor);
            if (animated)
            {
                [CollectionAnimationHelper animateChangeFrame:subView withNewFrame:subViewFrame];
            }
            else
            {
                subView.frame = subViewFrame;
            }
            //if we have an image on top of the stack that will be the subview of this image view which is the stack image
            for(UIView * stackTop in subView.subviews)
            {
                if ([stackTop isKindOfClass:[UIImageView class]])
                {
                    CGRect frame = CGRectMake(subView.frame.origin.x + subView.frame.size.width * IMG_OFFSET_X_RATE,
                                              subView.frame.origin.y + subView.frame.size.height * IMG_OFFSET_Y_RATE,
                                              subView.frame.size.width * IMG_SIZE_WIDTH_RATIO,
                                              subView.frame.size.height * IMG_SIZE_HEIGHT_RATIO);
                    
                    if (animated)
                    {
                        [CollectionAnimationHelper animateChangeFrame:stackTop
                                                         withNewFrame:frame];
                    }
                    else
                    {
                        stackTop.frame = frame;
                        
                    }
                }
                
            }
            
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
            textView.editable = NO;
            [subView removeFromSuperview];
            
            [self addSubview:textView];
            
        }
    }
}

-(void) resetSize
{
    self.frame = self.originalFrame;
    for(UIView * subView in self.subviews)
    {
        if ([subView isKindOfClass:[UIImageView class]])
        {
            subView.frame = self.bounds;
            for (UIView * stackTop in subView.subviews)
            {
                if ([stackTop isKindOfClass:[UIImageView class]])
                {
                    
                    stackTop.frame = CGRectMake(subView.frame.origin.x + subView.frame.size.width * IMG_OFFSET_X_RATE,
                                                subView.frame.origin.y + subView.frame.size.height * IMG_OFFSET_Y_RATE,
                                                subView.frame.size.width * IMG_SIZE_WIDTH_RATIO,
                                                subView.frame.size.height * IMG_SIZE_HEIGHT_RATIO);
                }
            }
        }
        else if ([subView isKindOfClass:[UITextView class]])
        {
            
            NSString * oldText = ((UITextView *)subView).text;
            CGRect textFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width * STARTING_POS_OFFSET_X ,
                                          self.bounds.origin.y + self.bounds.size.height * STARTING_POS_OFFSET_Y,
                                          self.bounds.size.width * TEXT_WIDHT_RATIO,
                                          self.bounds.size.height * TEXT_HEIGHT_RATIO);
            UITextView * textView = [[UITextView alloc] initWithFrame:textFrame];
            textView.font = [UIFont fontWithName:@"Cochin" size:17.0];
            [textView setBackgroundColor:[UIColor clearColor]];
            
            textView.text = oldText;
            textView.editable = NO;
            [subView removeFromSuperview];
            
            [self addSubview:textView];
        }
    }
    self.scaleOffset = 1;
}

-(BOOL) removeMainViewImage
{
    for (UIView * view in self.subviews)
    {
        if ([view isKindOfClass:[UIImageView class]])
        {
            for (UIView * lastImg in view.subviews)
            {
                if ([lastImg isKindOfClass:[UIImageView class]])
                {
                    [lastImg removeFromSuperview];
                    return YES;
                }
            }
        }
    }
    return NO;
}

//removes the main view from the stack and sets the next view as the main view and top
//of the stack if no item has higher priority for being the top of the stack
-(void) setNextMainViewWithNoteToRemove:(NoteView *) noteView
{
    //First if the note is the mainView and its a image type, remove it as the image of stack
    //Then figure out if there is another image to become the mainview if not choose the last
    //note
    //If the note
    //if note is not the main view don't bother
    if (noteView != self.mainView)
    {
        return;
    }
    //if its the main view then remove it as the mainView
    [noteView removeFromSuperview];
    [self.views removeObject:noteView];
    //in addition if it had an image remove that as the top of the stack image
    if ([noteView isKindOfClass:[ImageView class]])
    {
        [self removeMainViewImage];
    }
    
    //we now need to find a substitue for it
    //if we have any image notes use that
    ImageView * topView = nil;
    for (UIView * view in self.views){
        if ([view isKindOfClass:[ImageView class]]){
            topView = (ImageView *) view;
            [self layImage:topView.image];
            self.mainView = topView;
            [self setText:topView.text];
            break;
        }
        
    }
    //if we still couldnt find it then just select the last noteView and make that the
    //mainView
    if (topView == nil)
    {
        self.mainView = [self.views lastObject];
        [self setText:((NoteView *)[self.views lastObject]).text];
    }
}

-(void) setTopViewForNote:(NoteView *) newNote;
{
    if ([self.views containsObject:newNote])
    {
        self.mainView = newNote;
        [self setText:newNote.text];
        
        if ([newNote isKindOfClass:[ImageView class]])
        {
            [self layImage:((ImageView *) newNote).image];
        }
    }
    
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
