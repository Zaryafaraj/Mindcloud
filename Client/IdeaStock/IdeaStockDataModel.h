//
//  IdeaStockDataModel.h
//  IdeaStock
//
//  Created by Ali Fathalian on 3/28/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BulletinBoard.h"
#import "Note.h"
/**
 * The protocol for the datamodel. Includes essential behaviors for working with bulletin boards and notes. 
 */
@protocol IdeaStockDataModel <NSObject>

//list all the bulletinboards available
- (NSArray <BulletinBoard> *) getBulletinBoardsFromRoot;
- (void) addBulletinBoard: (BulletinBoard *) board;
- (NSArray <Note> *) getAllNotesForTheBulletinBoard: (BulletinBoard *) board;
- 






@end
