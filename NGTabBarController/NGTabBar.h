//
//  NGTabBar.h
//  NGTabBarController
//
//  Created by Tretter Matthias on 14.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGTabBarPosition.h"

typedef enum {
    NGTabBarLayoutStrategyStrungTogether        = 0,
    NGTabBarLayoutStrategyEvenlyDistributed,
    NGTabBarLayoutStrategyCentered
} NGTabBarLayoutStrategy;


@interface NGTabBar : UIScrollView

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, assign) NSUInteger selectedItemIndex;
@property (nonatomic, assign) NGTabBarPosition position;
@property (nonatomic, assign) NGTabBarLayoutStrategy layoutStrategy;
/** the padding to apply between items, not taken into account when layoutStrategy is EvenlyDistributed */
@property (nonatomic, assign) CGFloat itemPadding;

/** defaults to black */
@property (nonatomic, strong) UIColor *tintColor;
/** defaults to nil */
@property (nonatomic, strong) UIImage *backgroundImage;
/** flag whether the semi-transparent item highlight is shown */
@property (nonatomic, assign) BOOL showsItemHighlight;
/** defaults to white */
@property (nonatomic, strong) UIColor *itemHighlightColor;

- (void)selectItemAtIndex:(NSUInteger)index;
- (void)deselectSelectedItem;

@end
