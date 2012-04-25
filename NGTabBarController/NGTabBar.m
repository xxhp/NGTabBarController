#import "NGTabBar.h"
#import "NGTabBarItem.h"


@interface NGTabBar ()

- (CGFloat)dimensionToBeConsideredOfItem:(NGTabBarItem *)item;

@end

@implementation NGTabBar

@synthesize items = _items;
@synthesize selectedItemIndex = _selectedItemIndex;
@synthesize position = _position;
@synthesize layoutStrategy = _layoutStrategy;
@synthesize itemPadding = _itemPadding;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceHorizontal = NO;
        self.clipsToBounds = YES;
        
        _selectedItemIndex = 0;
        _layoutStrategy = NGTabBarLayoutStrategyStrungTogether;
        _itemPadding = 0.f;
        _position = kNGTabBarPositionDefault;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat currentFrameLeft = 0.f;
    CGFloat currentFrameTop = 0.f;
    CGFloat totalDimension = 0.f;
    // we change item padding in strategy evenly distributed but don't want to change iVar
    CGFloat appliedItemPadding = self.itemPadding;
    
    if (self.layoutStrategy == NGTabBarLayoutStrategyEvenlyDistributed || self.layoutStrategy == NGTabBarLayoutStrategyCentered) {
        // compute total dimension needed
        for (NGTabBarItem *item in self.items) {
            totalDimension += [self dimensionToBeConsideredOfItem:item];
            
            // we don't take padding only into account if we want to evenly distribute items
            if (self.layoutStrategy != NGTabBarLayoutStrategyEvenlyDistributed) {
                totalDimension += self.itemPadding;
            }
        }
        
        // for evenly distributed items we calculate a new item padding
        if (self.layoutStrategy == NGTabBarLayoutStrategyEvenlyDistributed) {
            // the total padding needed for the whole tabBar
            CGFloat totalPadding = NGTabBarIsVertical(self.position) ? self.bounds.size.height - totalDimension : self.bounds.size.width - totalDimension;
            
            // we apply the padding (items.count - 1) times (always between two items)
            if (self.items.count > 1) {
                appliedItemPadding = MAX(0.f,totalPadding / (self.items.count - 1));
            }
        }
        
        else if (self.layoutStrategy == NGTabBarLayoutStrategyCentered) {
            // we only add padding between icons but we added it for each item in the loop above
            totalDimension -= appliedItemPadding;
            
            if (NGTabBarIsVertical(self.position)) {
                currentFrameTop = floorf((self.bounds.size.height-totalDimension)/2.f);
            } else {
                currentFrameLeft = floorf((self.bounds.size.width-totalDimension)/2.f);
            }
        }
    }
    
    // re-position each item starting from current top/left
    for (NGTabBarItem *item in self.items) {
        CGRect frame = item.frame;

        frame.origin.y = currentFrameTop;
        frame.origin.x = currentFrameLeft;
        item.frame = frame;
        
        // move to next item position
        if (NGTabBarIsVertical(self.position)) {
            currentFrameTop += frame.size.height;
            currentFrameTop += appliedItemPadding;
        } else {
            currentFrameLeft += frame.size.width;  
            currentFrameLeft += appliedItemPadding;
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGTabBar
////////////////////////////////////////////////////////////////////////

- (void)setItems:(NSArray *)items {
    if (items != _items) {
        [_items performSelector:@selector(removeFromSuperview)];
        
        _items = items;
        
        for (NGTabBarItem *item in _items) {
            [self addSubview:item];
        }
        
        [self setNeedsLayout];
    }
}

- (void)setPosition:(NGTabBarPosition)position {
    if (position != _position) {
        _position = position;
        
        if (NGTabBarIsVertical(position)) {
            self.alwaysBounceVertical = YES;
        } else {
            self.alwaysBounceVertical = NO;
        }
        
        // TODO: re-compute contentSize
        
        [self setNeedsLayout];
    }
}

- (void)selectItemAtIndex:(NSUInteger)index {
    [self deselectSelectedItem];
    
    if (index < self.items.count) {
        NGTabBarItem *item = [self.items objectAtIndex:index];
        item.selected = YES;
        
        self.selectedItemIndex = index;
    }
}

- (void)deselectSelectedItem {
    if (self.selectedItemIndex < self.items.count) {
        NGTabBarItem *selectedItem = [self.items objectAtIndex:self.selectedItemIndex];
        
        selectedItem.selected = NO;
        self.selectedItemIndex = NSNotFound;
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (CGFloat)dimensionToBeConsideredOfItem:(NGTabBarItem *)item {
    if (NGTabBarIsVertical(self.position)) {
        return item.frame.size.height;
    } else {
        return item.frame.size.width;  
    }
}

@end
