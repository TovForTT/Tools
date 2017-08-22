//
//  BLCycleProgressView.h
//

#import <UIKit/UIKit.h>

@interface BLCycleProgressView : UIView
@property(nonatomic) float progress;                        // 0.0 .. 1.0, default is 0.0. values outside are pinned.
@property(nonatomic, strong, nullable) UIColor *progressTintColor; // default clera
@property(nonatomic, strong, nullable) UIColor *trackTintColor; // default white

@property (nonatomic, assign) float lineWidth; // default 5

+ (instancetype _Nullable )cycleProgressView;
+ (instancetype _Nullable )cycleProgressViewWithProgress:(float)progress;
@end
