//
//  ListTableViewController.h
//  
//
//  Created by Ali Fathalian on 4/21/13.
//
//

#import "ScrollViewRecyclerDelegate.h"
#import "TableAnimatorProtocol.h"
#import "TableLayoutManagerProtocol.h"
#import "ListDataSource.h"

@interface ListsViewController : UIViewController <UIScrollViewDelegate, ScrollViewRecyclerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) id<TableLayoutManagerProtocol> layoutManager;
@property (nonatomic, strong) id<TableAnimatorProtocol> animationManager;

@property (nonatomic, strong) id<ListDatasource> dataSource;

@property (nonatomic, strong) UIView<ListRowProtocol> * prototypeRow;

@property UIView <ListRowProtocol> * editingRow;

@property BOOL isInEditMode;

-(UIView<ListRowProtocol> *) addRowToTop;

-(void) removeRow:(UIView<ListRowProtocol> *) row;

-(void) scrollViewTapped:(UISwipeGestureRecognizer *) sender;

@end
