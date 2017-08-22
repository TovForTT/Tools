//
//  UIView+BL.m
//

#import "UIView+BL.h"
@implementation UIView (BL)
- (void)setCornerRadius:(CGFloat)cornerRadius shadowColor:(UIColor*)shadowColor shadowOffset:(CGSize)shadowOffset shadowOpacity:(CGFloat)shadowOpacity shadowRadius:(CGFloat)shadowRadius{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
    
    CALayer *subLayer = [CALayer layer];
    subLayer.backgroundColor = shadowColor.CGColor;
    subLayer.frame = CGRectMake(self.frame.origin.x-0.5, self.frame.origin.y - 0.5, self.frame.size.width-1, self.frame.size.height-1);
    subLayer.cornerRadius = cornerRadius;
    subLayer.masksToBounds = NO;
    subLayer.shadowColor = shadowColor.CGColor;
    subLayer.shadowOffset = shadowOffset;
    subLayer.shadowOpacity = shadowOpacity;
    subLayer.shadowRadius = shadowRadius;
    [self.superview.layer insertSublayer:subLayer below:self.layer];
    
    /*
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight|UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.path = path.CGPath;
    self.layer.mask = layer;
*/
}

- (void)setCornerRadius:(CGFloat)cornerRadius shadowRadius:(CGFloat)shadowRadius{
    [self setCornerRadius:cornerRadius shadowColor:[UIColor colorWithWhite:0 alpha:.3] shadowOffset:CGSizeZero shadowOpacity:1 shadowRadius:shadowRadius];
}
@end
