//
//  UIView+BL.h
//

#import <UIKit/UIKit.h>

@interface UIView (BL)
- (void)setCornerRadius:(CGFloat)cornerRadius shadowColor:(UIColor*)shadowColor shadowOffset:(CGSize)shadowOffset shadowOpacity:(CGFloat)shadowOpacity shadowRadius:(CGFloat)shadowRadius;

- (void)setCornerRadius:(CGFloat)cornerRadius shadowRadius:(CGFloat)shadowRadius;
@end
