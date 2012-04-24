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

@optional

/** Asks the delegate for the width of the UITableView that acts as the tabBar, if the tabBar is displayed at the left/right */
- (CGFloat)widthOfTabBarOfTabBarController:(NGTabBarController *)tabBarController;

/** Asks the delegate whether the specified view controller should be made active. */
- (BOOL)tabBarController:(NGTabBarController *)tabBarController 
shouldSelectViewController:(UIViewController *)viewController
                 atIndex:(NSUInteger)index;

/** Tells the delegate that the user selected an item in the tab bar. */
- (void)tabBarController:(NGTabBarController *)tabBarController 
 didSelectViewController:(UIViewController *)viewController
                 atIndex:(NSUInteger)index;

@end
