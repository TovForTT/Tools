//
//  UIViewController+BL_BackButtonHandler.h
//  Copyright © 2017年 Tov_. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (BL_BackButtonHandler)<BackButtonHandlerProtocol>

@end
