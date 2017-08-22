//
//  BaseTabBarController.m
//

#import "BaseTabBarController.h"
#import "PersonalViewController.h"
#import "BaseNavigationController.h"
#import "BaseTabbar.h"
#import "UIColor+BL.h"
#import "ImageSelectViewController.h"
#import "HomePageTableViewController.h"
#import "CommunityViewController.h"
@interface BaseTabBarController () <BaseTabbarDelegate>

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self initial];
    
}

- (void)initial {
    BaseNavigationController *homeNavigation = [[BaseNavigationController alloc] initWithRootViewController:[HomePageTableViewController new]];
    [self addChildVC:homeNavigation Title:@"模板" Image:[UIImage imageNamed:@"home_bottom_template"] SelectImage:[UIImage imageNamed:@"home_bottom_selected_template"]];
    
    ImageSelectViewController *imageSelectView = [[ImageSelectViewController alloc] init];
    [self addChildVC:[[BaseNavigationController alloc] initWithRootViewController:imageSelectView] Title:@"切图" Image:[UIImage imageNamed:@"home_bottom_edit-1"] SelectImage:[UIImage imageNamed:@"home_bottom_selected_edit"]];
    
    [self addChildVC:[[BaseNavigationController alloc] initWithRootViewController:[CommunityViewController new]] Title:@"广场" Image:[UIImage imageNamed:@"home_bottom_community"] SelectImage:[UIImage imageNamed:@"home_bottom_selected_community"]];
    
    [self addChildVC:[[BaseNavigationController alloc] initWithRootViewController:[PersonalViewController new]] Title:@"我的" Image:[UIImage imageNamed:@"home_bottom_personal"] SelectImage:[UIImage imageNamed:@"home_bottom_selected_personal"]];
    self.selectedIndex = 1;
//    BaseTabbar *tabbar = [BaseTabbar new];
//    tabbar.backgroundImage = [UIImage imageNamed:@"home_bottom_bg"];
//    tabbar.tabbarDelegate = self;
//    tabbar.shadowImage = [UIImage new];
//    
//    [self setValue:tabbar forKey:@"tabBar"];
}

- (void)addChildVC:(UIViewController *)vc Title:(NSString *)title Image:(UIImage *)image SelectImage:(UIImage *)selectImage{
    vc.title = title;
    vc.tabBarItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [vc.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName : RGB_COLOR(253, 62, 128)} forState:UIControlStateSelected];
    [self addChildViewController:vc];
}

- (void)BaseTabbarClickFentu {
//    self.selectedIndex = 1;
    ImageSelectViewController *imageSelectView = [[ImageSelectViewController alloc] init];
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:imageSelectView];
    [self presentViewController:nav animated:nil completion:^{
        
    }];
}


@end
