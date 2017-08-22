//
//  BaseTabbar.h
//

#import <UIKit/UIKit.h>

@protocol BaseTabbarDelegate <NSObject>

- (void)BaseTabbarClickFentu;

@end

@interface BaseTabbar : UITabBar

@property (nonatomic, weak) id<BaseTabbarDelegate> tabbarDelegate;

@end
