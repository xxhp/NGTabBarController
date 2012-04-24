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
    
    NGColoredViewController *vc1 = [[NGColoredViewController alloc] initWithNibName:nil bundle:nil];
    NGColoredViewController *vc2 = [[NGColoredViewController alloc] initWithNibName:nil bundle:nil];
    NGColoredViewController *vc3 = [[NGColoredViewController alloc] initWithNibName:nil bundle:nil];
    NGColoredViewController *vc4 = [[NGColoredViewController alloc] initWithNibName:nil bundle:nil];
    NGColoredViewController *vc5 = [[NGColoredViewController alloc] initWithNibName:nil bundle:nil];
    
    vc1.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"VC1" image:nil];
    vc2.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"VC2" image:nil];
    vc3.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"VC3" image:nil];
    vc4.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"VC4" image:nil];
    vc5.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"VC5" image:nil];
    
    NSArray *viewController = [NSArray arrayWithObjects:vc1,vc2,vc3,vc4,vc5,nil];
    
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


@end
