//
//  ImageView.h
//  IdeaStock
//
//  Created by Ali Fathalian on 5/27/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "NoteView.h"

@interface ImageView : NoteView

@property UIImage *image;

-(id) initWithFrame:(CGRect)frame
           andImage: (UIImage *) image;

-(id) initWithFrame:(CGRect)frame 
           andImage:(UIImage *)image 
              andID: (NSString *)ID;
@end
