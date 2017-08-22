//
//  UIView+Extension.m
//  Copyright © 2017年 Tov_. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (CGFloat)x {
    return self.bounds.origin.x;
}

- (CGFloat)y {
    return self.bounds.origin.y;
}

- (CGFloat)w {
    return self.bounds.size.width;
}

- (CGFloat)h {
    return self.bounds.size.height;
}

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setW:(CGFloat)w {
    CGRect frame = self.frame;
    frame.size.width = w;
    self.frame = frame;
}

- (void)setH:(CGFloat)h {
    CGRect frame = self.frame;
    frame.size.height = h;
    self.frame = frame;
}
@end
