//
//  MBProgressHUD+BL.h
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (BL)
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showText:(NSString*)text toView:(UIView *)view;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view dimBackground:(BOOL)falg;

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;


+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;
+ (void)showText:(NSString*)text;

+ (MBProgressHUD *)showMessage:(NSString *)message;
+ (MBProgressHUD *)showMessage:(NSString *)message dimBackground:(BOOL)falg;


+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end
