#import "NGTabBarItem.h"


#define kNGDefaultTintColor                 [UIColor colorWithRed:41.0/255.0 green:147.0/255.0 blue:239.0/255.0 alpha:1.0]
#define kNGDefaultTitleColor                [UIColor darkGrayColor]
#define kNGDefaultSelectedTitleColor        [UIColor whiteColor]

@interface NGTabBarItem () {
    BOOL _selectedByUser;
}

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation NGTabBarItem

@synthesize selected = _selected;
@synthesize selectedImageTintColor = _selectedImageTintColor;
@synthesize titleColor = _titleColor;
@synthesize selectedTitleColor = _selectedTitleColor;
@synthesize image = _image;
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
        _selectedByUser = NO;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:10.f];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.textColor = kNGDefaultTitleColor;
        [self addSubview:_titleLabel];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.image != nil) {
        CGRect textLabelFrame = CGRectMake(0.f, self.bounds.size.height-self.titleLabel.font.lineHeight,
                                           self.bounds.size.width,
                                           self.titleLabel.font.lineHeight);
        
        self.titleLabel.frame = textLabelFrame;
    } else {
        self.titleLabel.frame = self.bounds;
    }
}

- (void)drawRect:(CGRect)rect {
    CGRect bounds = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.image != nil) {
        CGContextSaveGState(context);
        
        // flip the coordinates system
        CGContextTranslateCTM(context, 0.0, bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // draw an image in the center of the cell (offset to the top)
        CGSize imageSize = self.image.size;
        CGRect imageRect = CGRectMake(floorf(((bounds.size.width-imageSize.width)/2.0)),
                                      floorf(((bounds.size.height-imageSize.height)/2.0)) + 5.f,
                                      imageSize.width,
                                      imageSize.height);
        
        // draw either a selection gradient/glow or a regular image
        if (_selectedByUser) {
            // setup shadow
            CGSize shadowOffset = CGSizeMake(0.0f, 1.0f);
            CGFloat shadowBlur = 3.0;
            CGColorRef cgShadowColor = [[UIColor blackColor] CGColor];
            
            // setup gradient
            CGFloat alpha0 = 0.8;
            CGFloat alpha1 = 0.6;
            CGFloat alpha2 = 0.0;
            CGFloat alpha3 = 0.1;
            CGFloat alpha4 = 0.5;
            CGFloat locations[5] = {0,0.55,0.55,0.7,1};
            
            CGFloat components[20] = {1,1,1,alpha0,1,1,1,alpha1,1,1,1,alpha2,1,1,1,alpha3,1,1,1,alpha4};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef colorGradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, (size_t)5);
            CGColorSpaceRelease(colorSpace);
            
            // set shadow
            CGContextSetShadowWithColor(context, shadowOffset, shadowBlur, cgShadowColor);
            
            // set transparency layer and clip to mask
            CGContextBeginTransparencyLayer(context, NULL);
            CGContextClipToMask(context, imageRect, [self.image CGImage]);
            
            // fill and end the transparency layer
            CGContextSetFillColorWithColor(context, [self.selectedImageTintColor CGColor]);
            CGContextFillRect(context, imageRect);
            CGPoint start = CGPointMake(CGRectGetMidX(imageRect), imageRect.origin.y);
            CGPoint end = CGPointMake(CGRectGetMidX(imageRect)-imageRect.size.height/4, imageRect.size.height+imageRect.origin.y);
            CGContextDrawLinearGradient(context, colorGradient, end, start, 0);
            CGContextEndTransparencyLayer(context);
            
            CGGradientRelease(colorGradient);
        } else {
            CGContextDrawImage(context, imageRect, self.image.CGImage);
        }
        
        CGContextRestoreGState(context);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIControl
////////////////////////////////////////////////////////////////////////

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    // somehow self.selected always returns NO, so we store it in our own iVar
    _selectedByUser = selected;
    
    if (selected) {
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.titleLabel.textColor = [UIColor lightGrayColor];
    }
    
    [self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGTabBarItem
////////////////////////////////////////////////////////////////////////

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
    
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (UIColor *)selectedImageTintColor {
    return _selectedImageTintColor ?: kNGDefaultTintColor;
}

- (UIColor *)titleColor {
    return _titleColor ?: kNGDefaultTitleColor;
}

- (UIColor *)selectedTitleColor {
    return _selectedTitleColor ?: kNGDefaultSelectedTitleColor;
}

@end
