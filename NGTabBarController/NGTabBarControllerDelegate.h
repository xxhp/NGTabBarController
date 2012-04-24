//
//  NGTabBarControllerDelegate.h
//  NGTabBarController
//
//  Created by Tretter Matthias on 14.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGTabBarPosition.h"

@class NGTabBarController;
@class NGTabBarItem;

@protocol NGTabBarControllerDelegate <NSObject>

@required

/** Asks the delegate for the size of the given item */
- (CGSize)tabBarController:(NGTabBarController *)tabBarController
sizeOfItemForViewController:(UIViewController *)viewController
                   atIndex:(NSUInteger)index
                  position:(NGTabBarPosition)position;

@optional

/** Asks the delegate whether the specified view controller should be made active. */
- (BOOL)tabBarController:(NGTabBarController *)tabBarController 
shouldSelectViewController:(UIViewController *)viewController
                 atIndex:(NSUInteger)index;

/** Tells the delegate that the user selected an item in the tab bar. */
- (void)tabBarController:(NGTabBarController *)tabBarController 
 didSelectViewController:(UIViewController *)viewController
                 atIndex:(NSUInteger)index;

@end
