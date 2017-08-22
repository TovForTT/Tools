//
//  FTTools.m
//

#import "FTTools.h"
#import <UIKit/UIKit.h>
#import "MBProgressHUD+BL.h"

@implementation FTTools

+ (void)showAlertView:(NSString *)tips {
    [MBProgressHUD hideHUD];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:tips delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

@end
