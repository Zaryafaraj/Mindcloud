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
#import "ListTableViewDatasource.h"

@interface ListTableViewController : UIViewController <UIScrollViewDelegate, ScrollViewRecyclerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) id<TableLayoutManagerProtocol> layoutManager;
@property (nonatomic, strong) id<TableAnimatorProtocol> animationManager;

@property (nonatomic, strong) id<ListTableViewDatasource> dataSource;

@property (nonatomic, strong) UIView<ListRow> * prototypeRow;

@property UIView <ListRow> * editingRow;

@property BOOL isInEditMode;

-(UIView<ListRow> *) addRowToTop;

-(void) removeRow:(UIView<ListRow> *) row;

-(void) scrollViewTapped:(UISwipeGestureRecognizer *) sender;

@end
