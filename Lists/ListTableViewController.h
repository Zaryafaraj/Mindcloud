//
//  ListTableViewController.h
//  
//
//  Created by Ali Fathalian on 4/21/13.
//
//


#import "ScrollViewRecyclerDelegate.h"
#import "ListTableAnimationManager.h"
#import "ListTableViewLayoutManager.h"
#import "ListTableViewDatasource.h"

@interface ListTableViewController : UIViewController <UIScrollViewDelegate, ScrollViewRecyclerDelegate>

@property (nonatomic, strong) id<ListTableViewLayoutManager> layoutManager;
@property (nonatomic, strong) id<ListTableAnimationManager> animationManager;

@property (nonatomic, strong) id<ListTableViewDatasource> dataSource;

@property (nonatomic, strong) UIView<ListRow> * prototypeRow;

-(void) addRowToTop;

-(void) removeRowFromIndex: (int) index;

@end
