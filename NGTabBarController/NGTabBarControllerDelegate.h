//
//  NGTabBarControllerDelegate.h
//  NGTabBarController
//
//  Created by Tretter Matthias on 14.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

@class NGTabBarController;
@class NGTabBarItem;

@protocol NGTabBarControllerDelegate <NSObject>

@required

/** Asks the delegate to customized the cell of the tabBar */
- (NGTabBarItem *)verticalTabBarController:(NGTabBarController *)tabBarController
                            customizedItem:(NGTabBarItem *)item
                         forViewController:(UIViewController *)viewController
                                   atIndex:(NSUInteger)index;

@optional

/** Asks the delegate for the width of the UITableView that acts as the tabBar */
- (CGFloat)widthOfTabBarOfVerticalTabBarController:(NGTabBarController *)tabBarController;

/** Asks the delegate fot the specific height of an NGTabBarCell */
- (CGFloat)heightForTabBarCell:(NGTabBarController *)taabBarController atIndex:(NSUInteger)index;

/** Asks the delegate whether the specified view controller should be made active. */
- (BOOL)verticalTabBarController:(NGTabBarController *)tabBarController 
      shouldSelectViewController:(UIViewController *)viewController
                         atIndex:(NSUInteger)index;

/** Tells the delegate that the user selected an item in the tab bar. */
- (void)verticalTabBarController:(NGTabBarController *)tabBarController 
         didSelectViewController:(UIViewController *)viewController
                         atIndex:(NSUInteger)index;

@end
