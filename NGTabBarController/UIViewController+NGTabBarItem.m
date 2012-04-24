//
//  UIViewController+NGTabBarItem.m
//  NGTabBarController
//
//  Created by Tretter Matthias on 24.04.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "UIViewController+NGTabBarItem.h"
#import "NGTabBarItem.h"
#import <objc/runtime.h>

static char itemKey;

@implementation UIViewController (NGTabBarItem)

- (void)ng_setTabBarItem:(NGTabBarItem *)ng_tabBarItem {
    objc_setAssociatedObject(self, &itemKey, ng_tabBarItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NGTabBarItem *)ng_tabBarItem {
    return objc_getAssociatedObject(self, &itemKey);
}

@end
