#import "NGTabBar.h"
#import "NGTabBarItem.h"


@interface NGTabBar ()

- (CGFloat)dimensionUsedOfItem:(NGTabBarItem *)item;

@end

@implementation NGTabBar

@synthesize items = _items;
@synthesize selectedItemIndex = _selectedItemIndex;
@synthesize position = _position;
@synthesize centerItems = _centerItems;

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
        _centerItems = NO;
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
    
    if (self.centerItems) {
        CGFloat totalDimension = 0.f;
        
        // compute total dimension
        for (NGTabBarItem *item in self.items) {
            totalDimension += [self dimensionUsedOfItem:item];
        }
        
        if (NGTabBarIsVertical(self.position)) {
            currentFrameTop = floorf((self.bounds.size.height-totalDimension)/2.f);
        } else {
            currentFrameLeft = floorf((self.bounds.size.width-totalDimension)/2.f);
        }
    }
    
    for (NGTabBarItem *item in self.items) {
        // re-position item
        CGRect frame = item.frame;
        frame.origin.y = currentFrameTop;
        frame.origin.x = currentFrameLeft;
        item.frame = frame;
        
        if (NGTabBarIsVertical(self.position)) {
            currentFrameTop += frame.size.height;
        } else {
            currentFrameLeft += frame.size.width;  
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

- (CGFloat)dimensionUsedOfItem:(NGTabBarItem *)item {
    if (NGTabBarIsVertical(self.position)) {
        return item.frame.size.height;
    } else {
        return item.frame.size.width;  
    }
}

@end
