//
//  AppDelegate.m
//  NGTabBarControllerDemo
//
//  Created by Tretter Matthias on 16.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "AppDelegate.h"
#import "NGColoredViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSArray *viewController = [NSArray arrayWithObjects:[[NGColoredViewController alloc] initWithNibName:nil bundle:nil],
                               [[NGColoredViewController alloc] initWithNibName:nil bundle:nil],
                               [[NGColoredViewController alloc] initWithNibName:nil bundle:nil],
                               [[NGColoredViewController alloc] initWithNibName:nil bundle:nil],
                               [[NGColoredViewController alloc] initWithNibName:nil bundle:nil],nil];
    
    NGTabBarController *tabBarController = [[NGTabBarController alloc] initWithDelegate:self];
    
    tabBarController.animation = NGTabBarControllerAnimationMoveAndScale;
    tabBarController.viewControllers = viewController;
    self.window.rootViewController = tabBarController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGTabBarControllerDelegate
////////////////////////////////////////////////////////////////////////

- (NGTabBarItem *)verticalTabBarController:(NGTabBarController *)tabBarController
                            customizedItem:(NGTabBarItem *)item
                         forViewController:(UIViewController *)viewController
                                   atIndex:(NSUInteger)index {
    item.textLabel.text = [NSString stringWithFormat:@"%d", index];
    
    return item;
}

@end
