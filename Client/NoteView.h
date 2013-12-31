//
//  NoteView.h
//  IdeaStock
//
//  Created by Ali Fathalian on 4/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BulletinBoardObject.h"
#import "NoteViewDelegate.h"

#define TEXT_X_OFFSET 20
#define TEXT_Y_OFFSET 20

@interface NoteView : UIView <BulletinBoardObject,UITextViewDelegate>

@property (weak,nonatomic) id<NoteViewDelegate> delegate;


/*! protected. Should not be used by subclasses
    Because objective c is a dynamic language
    we can't create strict protected methods.
    Maybe someday we will find a better design pattern
 */
@property (weak, nonatomic) UITextView * _textView;

-(instancetype) _configureView;

-(instancetype) _configurePrototype: (NoteView *) prototype;

-(void) resizeToRect:(CGRect) rect Animate: (BOOL) animate;

-(void) animateLayoutChangeForBounds:(CGRect) bounds
                        withDuration:(CGFloat) duration
                 andAnimationOptions:(UIViewAnimationOptions) options;

-(void) enablePaintMode;

-(void) disablePaintMode;

-(void) scaleWithScaleOffset:(CGFloat) scaleOffset
            fromOriginalSize:(CGSize) size
                    animated:(BOOL) animated;

-(instancetype) prototype;

-(UIView *) getEnclosingNoteView;

@end
