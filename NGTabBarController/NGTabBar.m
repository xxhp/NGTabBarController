#import "NGTabBar.h"
#import "NGTabBarItem.h"


@implementation NGTabBar

@synthesize items = _items;
@synthesize selectedItemIndex = _selectedItemIndex;
@synthesize position = _position;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        _selectedItemIndex = 0;
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
            item.frame = CGRectMake(0.f, 0.f, 44.f, 44.f);
            [self addSubview:item];
        }
        
        [self setNeedsLayout];
    }
}

- (void)setPosition:(NGTabBarPosition)position {
    if (position != _position) {
        _position = position;
        
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

@end
