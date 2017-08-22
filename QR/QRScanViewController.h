//
//  QRScanViewController.h
//  Copyright © 2017年 Tov_. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QRScanViewControllerDelegate <NSObject>

- (void)scanResult:(NSString *)result;

@end

@interface QRScanViewController : UIViewController

@property (nonatomic, weak) id<QRScanViewControllerDelegate> delegate;

@end
