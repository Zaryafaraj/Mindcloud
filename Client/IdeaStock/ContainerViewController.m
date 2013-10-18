//
//  ContainerViewController.m
//  Mindcloud
//
//  Created by Ali Fathalian on 9/23/13.
//  Copyright (c) 2013 University of Washington. All rights reserved.
//

#import "ContainerViewController.h"
#import "AllCollectionsViewController.h"
#import "AllCollectionsNavigationControllerViewController.h"
#import "MMDrawerVisualState.h"

@interface ContainerViewController()


@end
@implementation ContainerViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryBoard" bundle:nil];
        AllCollectionsNavigationControllerViewController * mainScreen = [storyboard instantiateViewControllerWithIdentifier:@"MainScreenNavigationController"];
        //this is a weak pointer
        mainScreen.parent = self;
        CategoriesViewController * categoriesScreen = [storyboard instantiateViewControllerWithIdentifier:@"CategoriesViewController"];
        self.leftPanel = categoriesScreen;
        
        //        mainScreen.categoriesController = categoriesScreen;
        self = [super initWithCenterViewController:mainScreen leftDrawerViewController:categoriesScreen];
        
        [self setShowsShadow:YES];
        [self setMaximumRightDrawerWidth:200.0];
        [self setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
        [self setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        
        [self setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
            MMDrawerControllerDrawerVisualStateBlock block = [MMDrawerVisualState swingingDoorVisualStateBlock];
            if(block){
                block(drawerController, drawerSide, percentVisible);
            }
        }];
    }
    return self;
}

-(void) toggleSidePanel
{
    [self toggleDrawerSide:MMDrawerSideLeft animated:YES
                completion:^(BOOL finished)
     {
         ;
     }];
}

-(void) disableLeftPanel
{
    self.openDrawerGestureModeMask = MMOpenDrawerGestureModeNone;
}

-(void) enableLeftPanel
{
    self.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
}

@end
