#import "NGTabBarItem.h"


@interface NGTabBarItem ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation NGTabBarItem

@synthesize selected = _selected;
@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

+ (NGTabBarItem *)itemWithTitle:(NSString *)title image:(UIImage *)image {
    NGTabBarItem *item = [[NGTabBarItem alloc] initWithFrame:CGRectZero];
    
    item.title = title;
    item.image = image;
    
    return item;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor redColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // TODO:
    self.titleLabel.frame = self.bounds;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGTabBarItem
////////////////////////////////////////////////////////////////////////

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    [self setNeedsLayout];
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (NSString *)title {
    return self.titleLabel.text;
}

@end
