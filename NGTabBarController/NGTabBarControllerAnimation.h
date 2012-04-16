//
//  NGTabBarControllerAnimation.h
//  NGTabBarController
//
//  Created by Tretter Matthias on 16.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

/**
 The animation used when we change the selected tabItem, default is none. Animations are only supported on iOS 5.
 */
typedef enum {
    NGTabBarControllerAnimationNone = 0,
    NGTabBarControllerAnimationFade,
    NGTabBarControllerAnimationCurl,
    NGTabBarControllerAnimationMove,
    NGTabBarControllerAnimationMoveAndScale
} NGTabBarControllerAnimation;