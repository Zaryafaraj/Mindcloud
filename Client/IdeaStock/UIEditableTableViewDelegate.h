//
//  UIEditableTableViewDelegate.h
//  Mindcloud
//
//  Created by Ali Fathalian on 11/5/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIEditableTableViewDelegate <NSObject, UITableViewDelegate>

-(void) tableView:(UITableView *)tableView
          renamed:(UITableViewCell *) selectedCell
      fromOldName:(NSString *) categoryName
        toNewName:(NSString *) newCategoryName;

-(BOOL) shouldRenameCategory:(NSString *) categoryName;

@end
