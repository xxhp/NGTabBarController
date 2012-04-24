//
//  NGTabBar.h
//  NGTabBarController
//
//  Created by Tretter Matthias on 14.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGTabBarPosition.h"

@interface NGTabBar : UIScrollView

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSUInteger selectedItemIndex;
@property (nonatomic, assign) NGTabBarPosition position;

@property (nonatomic, assign) BOOL centerItems;

- (void)selectItemAtIndex:(NSUInteger)index;
- (void)deselectSelectedItem;

@end
