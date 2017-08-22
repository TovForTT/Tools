//
//  BLCycleProgressView.m
//

#import "BLCycleProgressView.h"

@implementation BLCycleProgressView
+ (instancetype)cycleProgressView{
    BLCycleProgressView *progressView = [[BLCycleProgressView alloc] init];
    progressView.frame = CGRectMake(0, 0, 100, 100);
    progressView.lineWidth = 5;
    return progressView;
}

+ (instancetype)cycleProgressViewWithProgress:(float)progress{
    BLCycleProgressView *progressView = [BLCycleProgressView cycleProgressView];
    progressView.progress = progress;
    
    return progressView;
}

- (UIColor *)trackTintColor{
    if (!_trackTintColor) {
        _trackTintColor = [UIColor whiteColor];
    }
    return _trackTintColor;
}

- (UIColor *)progressTintColor{
    if (!_progressTintColor) {
        _progressTintColor = [UIColor clearColor];
    }
    return _progressTintColor;
}

- (float)lineWidth{
    if (_lineWidth > 50 || _lineWidth <=0) {
        _lineWidth = 5;
    }
    return _lineWidth;
}

- (void)setProgress:(float)progress{
    if (progress > 1) {
        progress = 1;
    }else if (progress < 0){
        progress = 0;
    }
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
     CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
     CGPoint center = self.center;  //设置圆心位置
     CGFloat radius = 90;  //设置半径
     CGFloat startA = - M_PI_2;  //圆起点位置
     CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;  //圆终点位置
 
     UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
 
     CGContextSetLineWidth(ctx, self.lineWidth); //设置线条宽度
     [_trackTintColor setStroke]; //设置描边颜色
     CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
     CGContextStrokePath(ctx);  //渲染
 }

@end
