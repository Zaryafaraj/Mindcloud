//
//  CollectionAnimationHelper.h
//  Mindcloud
//
//  Created by Ali Fathalian on 1/20/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteView.h"
#import "StackView.h"
#import "FunctionTypeDefs.h"

@interface CollectionAnimationHelper : NSObject

+(void) animateNoteAddition:(NoteView *)note
               toCollectionView:(UIView *) collectionView;

+(void) animateStackViewRemoval:(StackView *) stack;

+(void) animateStackCreationForStackView:(UIView *) stack
                            WithMainView:(UIView *) mainView
                            andStackItems:(NSArray*) items
                        inCollectionView: (UIView *) collectionView
                                   isNew:(BOOL) isNewStack
                    withMoveNoteFunction:(update_note_location_function) updateNote;

+(void) animateExpandNote: (UIView *) note
            InRect:(CGRect) noteRect;
+(void) animateMoveNote:(UIView *) view
backIntoScreenBoundsInRect:(CGRect) frame;

@end
