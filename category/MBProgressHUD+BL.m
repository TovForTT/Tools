//
//  MBProgressHUD+BL.m
//

#import "MBProgressHUD+BL.h"
@implementation MBProgressHUD (BL)
#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    // 快速显示一个提示信息
    
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    [MBProgressHUD hideHUDForView:view];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    hud.label.text = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    hud.alpha = 1.0;
    
    // 1.5秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    
    [self show:error icon:@"textEdit_cancel" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"textEdit_ok" view:view];
}

+ (void)showText:(NSString *)text toView:(UIView *)view
{
    [self show:text icon:nil view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view dimBackground:(BOOL)falg
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.backgroundColor = falg?[UIColor colorWithWhite:0.000 alpha:0.604]:[UIColor clearColor];
    
    return hud;
}

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view
{
    return [self showMessage:message toView:view dimBackground:YES];
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (void)showText:(NSString *)text
{
    [self showText:text toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message dimBackground:(BOOL)falg
{
    return [self showMessage:message toView:nil dimBackground:falg];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}
@end
