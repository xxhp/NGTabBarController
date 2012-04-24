//
//  NGTabBarPosition.h
//  NGTabBarController
//
//  Created by Tretter Matthias on 24.04.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

typedef enum {
    NGTabBarPositionTop = 0,
    NGTabBarPositionRight,
    NGTabBarPositionBottom,
    NGTabBarPositionLeft,
} NGTabBarPosition;

#define kNGTabBarPositionDefault    NGTabBarPositionLeft


NS_INLINE BOOL NGTabBarIsVertical(NGTabBarPosition position) {
    return position == NGTabBarPositionLeft || position == NGTabBarPositionRight;
}

NS_INLINE BOOL NGTabBarIsHorizontal(NGTabBarPosition position) {
    return position == NGTabBarPositionTop || position == NGTabBarPositionBottom;
}