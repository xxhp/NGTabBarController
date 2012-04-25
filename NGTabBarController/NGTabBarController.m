#import "NGTabBarController.h"


// the default width of the tabBar
#define kNGTabBarControllerDefaultWidth     150.0f
#define kNGTabBarCellDefaultHeight          120.0f
#define kNGDefaultAnimationDuration           0.3f
#define kNGScaleFactor                        0.98f
#define kNGScaleDuration                      0.15f


@interface NGTabBarController () {
    // re-defined as mutable
    NSMutableArray *_viewControllers;
    
    // flags for methods implemented in the delegate
    struct {
		unsigned int shouldSelectViewController:1;
		unsigned int didSelectViewController:1;
	} _delegateFlags;
    
    BOOL _moveAnimationActive;
}

// re-defined as read/write
@property (nonatomic, strong, readwrite) NGTabBar *tabBar;
@property (nonatomic, strong) NSArray *tabBarItems;
/** the (computed) frame of the sub-viewcontrollers */
@property (nonatomic, readonly) CGRect childViewControllerFrame;
@property (nonatomic, assign) NSUInteger oldSelectedIndex;
@property (nonatomic, readonly) BOOL containmentAPISupported;
@property (nonatomic, readonly) UIViewAnimationOptions currentActiveAnimationOptions;

- (void)updateUI;
- (void)layout;

- (BOOL)delegatedDecisionIfWeShouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)callDelegateDidSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (CGSize)delegatedSizeOfItemForViewController:(UIViewController *)viewController atIndex:(NSUInteger)index position:(NGTabBarPosition)position;

- (void)setupTabBarForPosition:(NGTabBarPosition)position;
- (void)handleItemPressed:(id)sender;

- (CGFloat)widthOrHeightOfTabBarForPosition:(NGTabBarPosition)position;

@end


@implementation NGTabBarController

@synthesize viewControllers = _viewControllers;
@synthesize selectedIndex = _selectedIndex;
@synthesize delegate = _delegate;
@synthesize tabBar = _tabBar;
@synthesize tabBarPosition = _tabBarPosition;
@synthesize animation = _animation;
@synthesize animationDuration = _animationDuration;
@synthesize tabBarItems = _tabBarItems;
@synthesize oldSelectedIndex = _oldSelectedIndex;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithDelegate:(id<NGTabBarControllerDelegate>)delegate {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _selectedIndex = NSNotFound;
        _oldSelectedIndex = NSNotFound;
        _animation = NGTabBarControllerAnimationNone;
        _animationDuration = kNGDefaultAnimationDuration;
        _moveAnimationActive = NO;
        _tabBarPosition = kNGTabBarPositionDefault;
        
        // need to call setter here
        self.delegate = delegate;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.delegate != nil, @"No delegate set");
    
    self.tabBar.items = self.tabBarItems;
    self.tabBar.position = self.tabBarPosition;
    
    [self setupTabBarForPosition:self.tabBarPosition];
    [self.view addSubview:self.tabBar];
}

- (void)viewDidUnload {
    self.tabBar = nil;
    
    if (self.containmentAPISupported) {
        [self.selectedViewController removeFromParentViewController];
    } else {
        [self.selectedViewController.view removeFromSuperview];
        self.selectedViewController.view = nil;
    }
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.selectedIndex != NSNotFound) {
        [self.tabBar selectItemAtIndex:self.selectedIndex];
    }
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController viewDidDisappear:animated];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self layout];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
        [self layout];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (!self.containmentAPISupported) {
        [self.selectedViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGTabBarController
////////////////////////////////////////////////////////////////////////

- (NGTabBar *)tabBar {
    if (_tabBar == nil) {
        _tabBar = [[NGTabBar alloc] initWithFrame:CGRectZero];
    }
    
    return _tabBar;
}

- (void)setDelegate:(id<NGTabBarControllerDelegate>)delegate {
    if (delegate != _delegate) {
        _delegate = delegate;
        
        // update delegate flags
        _delegateFlags.shouldSelectViewController = [delegate respondsToSelector:@selector(verticalTabBarController:shouldSelectViewController:atIndex:)];
        _delegateFlags.didSelectViewController = [delegate respondsToSelector:@selector(verticalTabBarController:didSelectViewController:atIndex:)];
    }
}

- (UIViewController *)selectedViewController {
    NSAssert(self.selectedIndex < self.viewControllers.count, @"Selected index is invalid");
    
    id selectedViewController = [self.viewControllers objectAtIndex:self.selectedIndex];
    
    if (selectedViewController == [NSNull null]) {
        return nil;
    }
    
    return selectedViewController;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    NSAssert([self.viewControllers containsObject:selectedViewController], @"View controller must be a part of the TabBar");
    
    // updates the UI
    self.selectedIndex = [self.viewControllers indexOfObject:selectedViewController];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    if (animated) {
        // TODO:
    } else {
        self.viewControllers = viewControllers;
    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (viewControllers != _viewControllers) {
        if (self.containmentAPISupported) {
            // remove old child view controller
            for (UIViewController *viewController in _viewControllers) {
                [viewController removeFromParentViewController];
            }
        }
        
        self.tabBarItems = [viewControllers valueForKey:@"ng_tabBarItem"];
        
        _viewControllers = [NSMutableArray arrayWithArray:viewControllers];
        
        CGRect childViewControllerFrame = self.childViewControllerFrame;
        
        // add new child view controller
        for (UIViewController *viewController in _viewControllers) {
            if (self.containmentAPISupported) {
                [self addChildViewController:viewController];
                [viewController didMoveToParentViewController:self];
            }
            
            viewController.view.frame = childViewControllerFrame;
            viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            viewController.view.clipsToBounds = YES;
        }
        
        if (self.selectedIndex == NSNotFound && _viewControllers.count > 0) {
            [self.view addSubview:[[_viewControllers objectAtIndex:0] view]];
            self.selectedIndex = 0;
        } else {
            [self updateUI];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex != _selectedIndex) {
        self.oldSelectedIndex = _selectedIndex;
        _selectedIndex = selectedIndex;
        
        [self updateUI];
    }
}

- (void)setTabBarPosition:(NGTabBarPosition)tabBarPosition {
    if (tabBarPosition != _tabBarPosition) {
        _tabBarPosition = tabBarPosition;
        self.tabBar.position = tabBarPosition;
        
        [self setupTabBarForPosition:tabBarPosition];
        [self.view setNeedsLayout];
    }
}

- (void)setTabBarItems:(NSArray *)tabBarItems {
    if (tabBarItems != _tabBarItems) {
        for (NGTabBarItem *item in _tabBarItems) {
            [item removeTarget:self action:@selector(handleItemPressed:) forControlEvents:UIControlEventTouchDown];
        }
        
        _tabBarItems = tabBarItems;
        
        for (NGTabBarItem *item in _tabBarItems) {
            [item addTarget:self action:@selector(handleItemPressed:) forControlEvents:UIControlEventTouchDown];
        }
        
        self.tabBar.items = tabBarItems;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)updateUI {
    if (self.selectedIndex != NSNotFound) {
        UIViewController *newSelectedViewController = self.selectedViewController;
        [self.tabBar selectItemAtIndex:self.selectedIndex];
        
        // show transition between old and new child viewcontroller
        if (self.oldSelectedIndex != NSNotFound) {
            UIViewController *oldSelectedViewController = [self.viewControllers objectAtIndex:self.oldSelectedIndex];
            
            if (self.containmentAPISupported) { 
                // custom move animation
                if (self.animation == NGTabBarControllerAnimationMove ||
                    self.animation == NGTabBarControllerAnimationMoveAndScale) {
                    CGRect frame = self.childViewControllerFrame;
                    
                    if (self.oldSelectedIndex < self.selectedIndex) {
                        if (NGTabBarIsVertical(self.tabBarPosition)) {
                            frame.origin.y = frame.size.height;
                        } else {
                            frame.origin.x = frame.size.width;
                        }
                    } else {
                        if (NGTabBarIsVertical(self.tabBarPosition)) {
                            frame.origin.y = -frame.size.height;
                        } else {
                            frame.origin.x = -frame.size.width;
                        }
                    }
                    
                    newSelectedViewController.view.frame = frame;
                    _moveAnimationActive = YES;
                    
                    if (self.animation == NGTabBarControllerAnimationMoveAndScale) {
                        [UIView animateWithDuration:kNGScaleDuration
                                         animations:^{
                                             oldSelectedViewController.view.transform = CGAffineTransformMakeScale(kNGScaleFactor, kNGScaleFactor);
                                             newSelectedViewController.view.transform = CGAffineTransformMakeScale(kNGScaleFactor, kNGScaleFactor);
                                         }];
                    }
                }
                
                // if the user switches tabs too fast the viewControllers disappear from view hierarchy
                // this is a workaround to not allow the user to switch during an animated transition
                self.tabBar.userInteractionEnabled = NO;
                
                [self transitionFromViewController:oldSelectedViewController
                                  toViewController:newSelectedViewController
                                          duration:self.animationDuration
                                           options:self.currentActiveAnimationOptions
                                        animations:^{
                                            if (self.animation == NGTabBarControllerAnimationMove ||
                                                self.animation == NGTabBarControllerAnimationMoveAndScale) {
                                                CGRect frame = oldSelectedViewController.view.frame;
                                                
                                                newSelectedViewController.view.frame = frame;
                                                
                                                if (self.oldSelectedIndex < self.selectedIndex) {
                                                    if (NGTabBarIsVertical(self.tabBarPosition)) {
                                                        frame.origin.y = -frame.size.height;
                                                    } else {
                                                        frame.origin.x = -frame.size.width;
                                                    }
                                                } else {
                                                    if (NGTabBarIsVertical(self.tabBarPosition)) {
                                                        frame.origin.y = frame.size.height;
                                                    } else {
                                                        frame.origin.x = frame.size.width;
                                                    }
                                                }
                                                
                                                oldSelectedViewController.view.frame = frame;
                                            }
                                        } completion:^(BOOL finished) {
                                            self.tabBar.userInteractionEnabled = YES;
                                            
                                            if (self.animation == NGTabBarControllerAnimationMoveAndScale) {
                                                [UIView animateWithDuration:kNGScaleDuration
                                                                 animations:^{
                                                                     oldSelectedViewController.view.transform = CGAffineTransformMakeScale(1.f, 1.f);
                                                                     newSelectedViewController.view.transform = CGAffineTransformMakeScale(1.f, 1.f);
                                                                 } completion:^(BOOL finished) {
                                                                     newSelectedViewController.view.frame = self.childViewControllerFrame;
                                                                     _moveAnimationActive = NO;
                                                                     
                                                                     // call the delegate that we changed selection
                                                                     [self callDelegateDidSelectViewController:newSelectedViewController atIndex:self.selectedIndex];
                                                                 }];
                                            } else {
                                                _moveAnimationActive = NO;
                                                // call the delegate that we changed selection
                                                [self callDelegateDidSelectViewController:newSelectedViewController atIndex:self.selectedIndex];
                                            }
                                        }];
            }
            
            // no containment API (< iOS 5)
            else {
                [oldSelectedViewController viewWillDisappear:NO];
                [newSelectedViewController viewWillAppear:NO];
                newSelectedViewController.view.frame = self.childViewControllerFrame;
                [self.view addSubview:newSelectedViewController.view];
                [newSelectedViewController viewDidAppear:NO];
                [oldSelectedViewController.view removeFromSuperview];
                [oldSelectedViewController viewDidDisappear:NO];
                
                // call the delegate that we changed selection
                [self callDelegateDidSelectViewController:newSelectedViewController atIndex:self.selectedIndex];
            }
        }
        
        // no old selected index path
        else {
            if (!self.containmentAPISupported) {
                newSelectedViewController.view.frame = self.childViewControllerFrame;
                [self.view addSubview:newSelectedViewController.view];
            }
        }
    } else {
        [self.tabBar deselectSelectedItem];
    }
}

- (void)layout {
    CGRect childViewControllerFrame = self.childViewControllerFrame;
    
    if (!_moveAnimationActive) {
        for (UIViewController *viewController in self.viewControllers) {
            viewController.view.frame = childViewControllerFrame;
        }
    }
    
    [self setupTabBarForPosition:self.tabBarPosition];
}

- (CGRect)childViewControllerFrame {
    CGRect bounds = self.view.bounds;
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    CGFloat inset = [self widthOrHeightOfTabBarForPosition:self.tabBarPosition];
    
    switch (self.tabBarPosition) {
        case NGTabBarPositionTop:
            edgeInsets = UIEdgeInsetsMake(inset, 0.f, 0.f, 0.f);
            break;
            
        case NGTabBarPositionRight:
            edgeInsets = UIEdgeInsetsMake(0.f, 0.f, 0.f, inset);
            break;
            
        case NGTabBarPositionBottom:
            edgeInsets = UIEdgeInsetsMake(0.f, 0.f, inset, 0.f);
            break;
            
        case NGTabBarPositionLeft:
            edgeInsets = UIEdgeInsetsMake(0.f, inset, 0.f, 0.f);
        default:
            break;
    }
    
    
    return UIEdgeInsetsInsetRect(bounds, edgeInsets);
}

- (BOOL)containmentAPISupported {
    // containment API is supported on iOS 5 and up
    static BOOL containmentAPISupported;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        containmentAPISupported = ([self respondsToSelector:@selector(willMoveToParentViewController:)] &&
                                   [self respondsToSelector:@selector(didMoveToParentViewController:)] && 
                                   [self respondsToSelector:@selector(transitionFromViewController:toViewController:duration:options:animations:completion:)]);
    });
    
    return containmentAPISupported;
}

- (UIViewAnimationOptions)currentActiveAnimationOptions {
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionTransitionNone;
    
    switch (self.animation) {    
        case NGTabBarControllerAnimationFade:
            animationOptions = UIViewAnimationOptionTransitionCrossDissolve;
            break;
            
        case NGTabBarControllerAnimationCurl:
            animationOptions = (self.oldSelectedIndex > self.selectedIndex) ? UIViewAnimationOptionTransitionCurlDown : UIViewAnimationOptionTransitionCurlUp;
            break;
            
        case NGTabBarControllerAnimationMove:
        case NGTabBarControllerAnimationMoveAndScale:
            // this animation is done manually.
            animationOptions = UIViewAnimationOptionLayoutSubviews;
            break;
            
            
        case NGTabBarControllerAnimationNone:
        default:
            // do nothing
            break;
    }
    
    return animationOptions;
}

- (void)setupTabBarForPosition:(NGTabBarPosition)position {
    CGRect frame = CGRectZero;
    UIViewAutoresizing autoresizingMask = UIViewAutoresizingNone;
    CGFloat dimension = [self widthOrHeightOfTabBarForPosition:position];
    
    switch (position) {
        case NGTabBarPositionTop: {
            frame = CGRectMake(0.f, 0.f, self.view.bounds.size.width, dimension);
            autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
            break;
        }
            
        case NGTabBarPositionRight: {
            frame = CGRectMake(self.view.bounds.size.width - dimension, 0.f, dimension, self.view.bounds.size.height);
            autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
            break;
        }
            
        case NGTabBarPositionBottom: {
            frame = CGRectMake(0.f, self.view.bounds.size.height - dimension, self.view.bounds.size.width, dimension);
            autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            break;
        }
            
        case NGTabBarPositionLeft:
        default: {
            frame = CGRectMake(0.f, 0.f, dimension, self.view.bounds.size.height);
            autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
            break;
        }
    }
    
    self.tabBar.frame = frame;
    self.tabBar.autoresizingMask = autoresizingMask;
    
    for (NSUInteger index = 0; index < self.viewControllers.count; index++) {
        UIViewController *viewController = [self.viewControllers objectAtIndex:index];
        NGTabBarItem *item = [self.tabBarItems objectAtIndex:index];
        
        [item setSize:[self delegatedSizeOfItemForViewController:viewController atIndex:index position:position]];
    }
}

- (void)handleItemPressed:(id)sender {
    NSInteger index = [self.tabBarItems indexOfObject:sender];
    BOOL shouldSelect = [self delegatedDecisionIfWeShouldSelectViewController:[self.viewControllers objectAtIndex:index] atIndex:index];
    
    if (shouldSelect && index != self.selectedIndex) {
        self.selectedIndex = index;
    }
}

- (CGFloat)widthOrHeightOfTabBarForPosition:(NGTabBarPosition)position {
    CGFloat dimension = kNGTabBarControllerDefaultWidth;
    
    // first item is responsible for dimension of tabBar, all must be equal (will not be checked)
    if (self.viewControllers.count > 0) {
        CGSize size = [self delegatedSizeOfItemForViewController:[self.viewControllers objectAtIndex:0] atIndex:0 position:position];
        
        if (NGTabBarIsVertical(position)) {
            dimension = size.width;
        } else {
            dimension = size.height;
        }
    }
    
    return dimension;
}

- (BOOL)delegatedDecisionIfWeShouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (_delegateFlags.shouldSelectViewController) {
        return [self.delegate tabBarController:self shouldSelectViewController:viewController atIndex:index];
    }
    
    // default: the view controller can be selected
    return YES;
}

- (void)callDelegateDidSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index {
    if (_delegateFlags.didSelectViewController) {
        [self.delegate tabBarController:self didSelectViewController:viewController atIndex:index];
    }
}

- (CGSize)delegatedSizeOfItemForViewController:(UIViewController *)viewController atIndex:(NSUInteger)index position:(NGTabBarPosition)position {
    return [self.delegate tabBarController:self sizeOfItemForViewController:viewController atIndex:index position:position];
}

@end
