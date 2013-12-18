//
//  IntroScreenCollaborationCordinator.m
//  Mindcloud
//
//  Created by Ali Fathalian on 12/17/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "IntroScreenCollaborationCordinator.h"
#import "ImageNoteView.h"

@interface IntroScreenCollaborationCordinator()

@property (nonatomic, strong) TutorialScrollView * leftView;
@property (nonatomic, strong) TutorialScrollView * rightView;
@property (nonatomic, strong) ImageNoteView * prototypeImageNote;
@property (nonatomic, strong) NoteView * prototypeNoteView;

@end

@implementation IntroScreenCollaborationCordinator

-(instancetype) initWithLeftView:(TutorialScrollView *)leftView
                    andRightView:(TutorialScrollView *)rightView
{
    self = [super init];
    if (self)
    {
        self.leftView = leftView;
        self.leftView.animationDelegate = self;
        self.rightView = rightView;
        self.rightView.animationDelegate = self;
    }
    return self;
}


-(void) animationFinished:(id)sender
{
    
    if (sender == self.rightView)
    {
        [self.leftView displayContent:YES];
    }
    if (sender == self.leftView)
    {
//        NoteView * noteView1 = [self createNoteViewWithPrototype:self.prototypeNoteView
//                                                    forPaintView:self.leftView.paintView];
//        
//        noteView1.transform = CGAffineTransformScale(noteView1.transform, 0.01, 0.01);
//        noteView1.hidden = YES;
//        
//        [UIView animateWithDuration:0.6
//                              delay:0.2
//             usingSpringWithDamping:0.4
//              initialSpringVelocity:2.0
//                            options:UIViewAnimationOptionCurveEaseIn
//                         animations:^{
//                             noteView1.hidden = NO;
//                             noteView1.transform = CGAffineTransformScale(noteView1.transform, 100, 100);
//                         }completion:^(BOOL completed){
//                             NoteView * noteView2 = [self createNoteViewWithPrototype:self.prototypeNoteView
//                                                                         forPaintView:self.rightView.paintView];
//                             noteView2.transform = CGAffineTransformScale(noteView2.transform, 0.01, 0.01);
//                             noteView2.hidden = YES;
//                             
//                             [UIView animateWithDuration:0.6
//                                                   delay:0.5
//                                  usingSpringWithDamping:0.4
//                                   initialSpringVelocity:2.0
//                                                 options:UIViewAnimationOptionCurveEaseIn
//                                              animations:^{
//                                                  
//                                                  noteView2.hidden = NO;
//                                                  noteView2.transform = CGAffineTransformScale(noteView2.transform, 100, 100);
//                                                  
//                                              }completion:^(BOOL completed){
//                                              }];
//                         }];
    }
}

-(void) animationStopped:(id)sender
{
    
    [self.leftView displayContent:YES];
}

-(void) startAnimationsWithImagePrototype:(ImageNoteView *) prototypeImageNote
                         andNotePrototype:(NoteView *) noteViewPrototype
{
    
    self.prototypeNoteView = noteViewPrototype;
    ImageNoteView * imageNoteView1 = [self createImageNoteViewWithPrototype:prototypeImageNote
                                                               forPaintView:self.leftView.paintView];
    
    imageNoteView1.transform = CGAffineTransformScale(imageNoteView1.transform, 0.01, 0.01);
    imageNoteView1.hidden = YES;
    [UIView animateWithDuration:0.6
                          delay:0.2
         usingSpringWithDamping:0.4
          initialSpringVelocity:2.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         imageNoteView1.hidden = NO;
                         imageNoteView1.transform = CGAffineTransformScale(imageNoteView1.transform, 100, 100);
                     }completion:^(BOOL completed){
                         ImageNoteView * imageNoteView2 = [self createImageNoteViewWithPrototype:prototypeImageNote
                                                                                    forPaintView:self.rightView.paintView];
                         imageNoteView2.transform = CGAffineTransformScale(imageNoteView2.transform, 0.01, 0.01);
                         imageNoteView1.hidden = YES;
                         
                         [UIView animateWithDuration:0.6
                                               delay:0.1
                              usingSpringWithDamping:0.4
                               initialSpringVelocity:2.0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              
                                              imageNoteView1.hidden = NO;
                                              imageNoteView2.transform = CGAffineTransformScale(imageNoteView2.transform, 100, 100);
                                              
                                          }completion:^(BOOL completed){
                                              self.rightView.stopPoint = 0;
                                              [self.rightView displayContent:YES];
                                          }];
                     }];
}


-(ImageNoteView *) createImageNoteViewWithPrototype:(ImageNoteView *) prototype
                                       forPaintView:(TutorialPaintView *) paintView
{
    
    ImageNoteView * imageNoteView = [prototype prototype];
    imageNoteView.alpha = 1;
    UIImage * image = [UIImage imageNamed:@"intro-colab-img"];
    imageNoteView.resizesToFitImage = NO;
    imageNoteView.image = image;
    imageNoteView.translatesAutoresizingMaskIntoConstraints = NO;
    imageNoteView.userInteractionEnabled = NO;
    
    [paintView addSubview:imageNoteView];
    
    NSDictionary * viewDicts = NSDictionaryOfVariableBindings(imageNoteView);
    NSString * imageConstraintH = @"H:|-30-[imageNoteView(==250)]";
    NSString * imageConstraintV = @"V:|-100-[imageNoteView(==140)]";
    
    [paintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:imageConstraintH
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDicts]];
    
    [paintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:imageConstraintV
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDicts]];
    return imageNoteView;
}

-(NoteView *) createNoteViewWithPrototype:(NoteView *) prototype forPaintView:(TutorialPaintView *) paintView
{
    
    NoteView * noteView = [prototype prototype];
    noteView.alpha = 1;
    noteView.translatesAutoresizingMaskIntoConstraints = NO;
    noteView.text = @"It looks like there were some problems with the systems on thursday";
    
    [paintView addSubview:noteView];
    
    NSDictionary * viewDicts = NSDictionaryOfVariableBindings(noteView);
    NSString * noteConstraintH = @"H:|-70-[noteView(==180)]";
    NSString * noteConstraintV = @"V:|-250-[noteView(==130)]";
    
    [paintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:noteConstraintH
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDicts]];
    
    [paintView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:noteConstraintV
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDicts]];
    return noteView;
}

@end
