//
//  BaseNavigationController.m
//

#import "BaseNavigationController.h"
#import "Static.h"
@interface BaseNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
    
    self.navigationBar.tintColor = RGB_COLOR(36, 36, 36);
    self.navigationBar.titleTextAttributes = @{
                                               NSForegroundColorAttributeName:RGB_COLOR(36, 36, 36), NSFontAttributeName : [UIFont systemFontOfSize:20]
                                               };
    self.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationBar.translucent = NO;

    self.navigationBar.backIndicatorImage = [UIImage imageNamed:@"edit_title_return"];
    self.navigationBar.backIndicatorTransitionMaskImage = [UIImage imageNamed:@"edit_title_return"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (self.viewControllers.count > 0) {
        
        viewController.hidesBottomBarWhenPushed = YES;
        
        self.interactivePopGestureRecognizer.delegate = (id)self;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    return self.childViewControllers.count > 1;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
