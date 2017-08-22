//
//  QRView.h
//  Copyright © 2017年 Tov_. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QRView;

@protocol QRViewDelegate <NSObject>

- (void)qrView:(QRView *)view ScanResult:(NSString *)result;
- (void)showAlert;

@end


@interface QRView : UIView

@property (nonatomic, assign) id<QRViewDelegate> delegate;

@property (nonatomic, assign) CGRect scanViewFrame;

- (void)initView;

- (void)startScan;

- (void)stopScan;

- (void)changeViewColor:(UIColor *)color andAlpha:(CGFloat)alpha;
@end
