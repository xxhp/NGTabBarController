#import "NGTabBar.h"
#import "NGTabBarItem.h"
#import <QuartzCore/QuartzCore.h>


#define kNGDefaultTintColor             [UIColor blackColor]
#define kNGDefaultItemHighlightColor    [UIColor colorWithWhite:1.f alpha:0.2f]


@interface NGTabBar () {
    CGGradientRef _gradientRef;
}

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *itemHighlightView;

- (void)createGradient;
- (void)updateItemHighlight;
- (CGFloat)dimensionToBeConsideredOfItem:(NGTabBarItem *)item;

@end


@implementation NGTabBar

@synthesize items = _items;
@synthesize selectedItemIndex = _selectedItemIndex;
@synthesize position = _position;
@synthesize layoutStrategy = _layoutStrategy;
@synthesize itemPadding = _itemPadding;
@synthesize tintColor = _tintColor;
@synthesize backgroundImage = _backgroundImage;
@synthesize backgroundView = _backgroundView;
@synthesize itemHighlightView = _itemHighlightView;
@synthesize showsItemHighlight = _showsItemHighlight;
@synthesize itemHighlightColor = _itemHighlightColor;

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
        _showsItemHighlight = YES;
        
        [self createGradient];
        [self updateItemHighlight];
    }
    
    return self;
}

- (void)dealloc {
    if (_gradientRef != NULL) {
        CFRelease(_gradientRef);
    }
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
    
    // backgroundView gets same frame as tabBar
    self.backgroundView.frame = self.bounds;
    
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
    
    // re-compute content size
    NGTabBarItem *lastItem = [self.items lastObject];
    
    if (NGTabBarIsVertical(self.position)) {
        self.contentSize = CGSizeMake(lastItem.frame.size.width, lastItem.frame.origin.y + lastItem.frame.size.height);
    } else {
        self.contentSize = CGSizeMake(lastItem.frame.origin.x + lastItem.frame.size.width, lastItem.frame.size.height);
    }
    
    [self updateItemHighlight];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.backgroundImage == nil) {
        CGRect bounds = self.bounds;
        CGPoint start;
        CGPoint end;
        
        // draw gradient
        CGContextSaveGState(context);
        CGContextClipToRect(context, bounds);
        
        if (self.position == NGTabBarPositionBottom) {
            start = CGPointMake(bounds.origin.x, bounds.origin.y);
            end = CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height);
        } else if (self.position == NGTabBarPositionTop) {
            start = CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height);
            end = CGPointMake(bounds.origin.x, bounds.origin.y);
        } else if (self.position == NGTabBarPositionLeft) {
            start = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y);
            end = CGPointMake(bounds.origin.x, bounds.origin.y);
        } else if (self.position == NGTabBarPositionRight) {
            start = CGPointMake(bounds.origin.x, bounds.origin.y);
            end = CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y);
        }
        
        CGContextDrawLinearGradient(context, _gradientRef, start, end, 0);
        CGContextRestoreGState(context);
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
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (void)selectItemAtIndex:(NSUInteger)index {
    [self deselectSelectedItem];
    
    if (index < self.items.count) {
        NGTabBarItem *item = [self.items objectAtIndex:index];
        item.selected = YES;
        
        self.selectedItemIndex = index;
        [self updateItemHighlight];
    }
}

- (void)deselectSelectedItem {
    if (self.selectedItemIndex < self.items.count) {
        NGTabBarItem *selectedItem = [self.items objectAtIndex:self.selectedItemIndex];
        
        selectedItem.selected = NO;
        self.selectedItemIndex = NSNotFound;
        [self updateItemHighlight];
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (backgroundImage != _backgroundImage) {
        [self.backgroundView removeFromSuperview];
        _backgroundImage = backgroundImage;
        
        if (backgroundImage != nil) {
            // is the image a non-resizable image?
            if (UIEdgeInsetsEqualToEdgeInsets(backgroundImage.capInsets,UIEdgeInsetsZero)) {
                self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
                self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
                [self insertSubview:self.backgroundView atIndex:0];
            } else {
                self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
            }
        } else {
            self.backgroundView = nil;
        }
    }
}

- (UIColor *)tintColor {
    return _tintColor ?: kNGDefaultTintColor;
}

- (void)setTintColor:(UIColor *)tintColor {
    if (tintColor != _tintColor) {
        _tintColor = tintColor;
        [self createGradient];
        [self setNeedsDisplay];
    }
}

- (UIColor *)itemHighlightColor {
    return _itemHighlightColor ?: kNGDefaultItemHighlightColor;
}

- (void)setItemHighlightColor:(UIColor *)itemHighlightColor {
    if (itemHighlightColor != _itemHighlightColor) {
        _itemHighlightColor = itemHighlightColor;
        [self updateItemHighlight];
    }
}

- (void)setShowsItemHighlight:(BOOL)showsItemHighlight {
    if (showsItemHighlight != _showsItemHighlight) {
        _showsItemHighlight = showsItemHighlight;
        [self updateItemHighlight];
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

- (void)createGradient {
    if (_gradientRef != NULL) {
        CFRelease(_gradientRef);
    }
    
    UIColor *baseColor = self.tintColor;
    CGFloat hue, saturation, brightness, alpha;
    NSArray *colors = nil;
    
    // TODO: This is a temporary workaround because getHue:saturation:brightness:alpha: is iOS 5 and up
    // We need a better way of drawing a TabBar-Gradient
    if ([baseColor respondsToSelector:@selector(getHue:saturation:brightness:alpha:)]) {
        [baseColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
        
        colors = [NSArray arrayWithObjects:
                  [UIColor colorWithHue:hue saturation:saturation brightness:brightness+0.2 alpha:alpha],
                  [UIColor colorWithHue:hue saturation:saturation brightness:brightness+0.15 alpha:alpha],
                  [UIColor colorWithHue:hue saturation:saturation brightness:brightness+0.1 alpha:alpha],
                  baseColor, nil];
    } else {
        colors = [NSArray arrayWithObjects:
                  baseColor,
                  baseColor,
                  baseColor,
                  baseColor, nil];
    }
    
    NSUInteger colorsCount = colors.count;
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors objectAtIndex:0] CGColor]);
    
    NSArray *locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], 
                          [NSNumber numberWithFloat:0.25], 
                          [NSNumber numberWithFloat:0.49], 
                          [NSNumber numberWithFloat:0.5], nil];
    CGFloat *gradientLocations = NULL;
    NSUInteger locationsCount = locations.count;
    
    gradientLocations = (CGFloat *)malloc(sizeof(CGFloat) * locationsCount);
    
    for (NSUInteger i = 0; i < locationsCount; i++) {
        gradientLocations[i] = [[locations objectAtIndex:i] floatValue];
    }
    
    NSMutableArray *gradientColors = [[NSMutableArray alloc] initWithCapacity:colorsCount];
    [colors enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
		[gradientColors addObject:(id)[(UIColor *)object CGColor]];
	}];
    
    _gradientRef = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
    
    if (gradientLocations) {
        free(gradientLocations);
    }
}

- (void)updateItemHighlight {
    if (self.selectedItemIndex != NSNotFound) {
        CGRect itemRect = [[self.items objectAtIndex:self.selectedItemIndex] frame]; 
        
        if (_itemHighlightView == nil) {
            self.itemHighlightView = [[UIView alloc] initWithFrame:CGRectZero];
            self.itemHighlightView.layer.cornerRadius = 5.f;
            [self addSubview:self.itemHighlightView];
        }
        
        self.itemHighlightView.backgroundColor = self.itemHighlightColor;
        self.itemHighlightView.frame = NGTabBarIsVertical(self.position) ? CGRectInset(itemRect, 2.f, 0.f) : CGRectInset(itemRect, 0.f, 2.f);
        self.itemHighlightView.hidden = !self.showsItemHighlight;
    } else {
        self.itemHighlightView.hidden = YES;
    }
}

@end
