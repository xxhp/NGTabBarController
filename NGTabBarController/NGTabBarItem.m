#import "NGTabBarItem.h"
#import "NGTabBar.h"

@implementation NGTabBarItem

+ (id)itemForTabBar:(NGTabBar *)tabBar {
    NSString *reuseIdentifier = NSStringFromClass([self class]);
    NGTabBarItem *cell = [tabBar dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (cell == nil) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    
    return cell; 
}

@end
