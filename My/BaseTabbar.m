//
//  BaseTabbar.m
//

#import "BaseTabbar.h"
#import "Static.h"
#import "UIView+Extension.h"

@implementation BaseTabbar {
    UIButton *fentuBtn;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    int i = 0;
    fentuBtn = [[UIButton alloc] init];
    fentuBtn.x = kScreen_Width / 3 + ((kScreen_Width / 3 - 64) * 0.5);
    fentuBtn.y = -20;
    fentuBtn.w = 64;
    fentuBtn.h = 64;
    fentuBtn.layer.cornerRadius = 32;
    fentuBtn.layer.masksToBounds = YES;
//    fentuBtn.backgroundColor = [UIColor orangeColor];
    [fentuBtn setImage:[UIImage imageNamed:@"home_bottom_edit"] forState:UIControlStateNormal];
    [fentuBtn setImage:[UIImage imageNamed:@"home_bottom_edit"] forState:UIControlStateHighlighted];
//    [fentuBtn.imageView setTintColor:[UIColor orangeColor]];
    [fentuBtn addTarget:self action:@selector(didClickFentu) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:fentuBtn];
    
    for (UIView *v in self.subviews) {
        if ([v isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (i > 0) {
                v.frame = CGRectMake(2 * kScreen_Width / 3, 0, kScreen_Width / 3, self.bounds.size.height);
                if (i == 1) {
                    v.hidden = YES;
                }
            } else {
                v.frame = CGRectMake(0, 0, kScreen_Width / 3, self.bounds.size.height);
                
            }
            
            i ++;
        } else {
            v.subviews.lastObject.hidden = YES;
        }
    }
}

- (void)didClickFentu {
    if ([self.tabbarDelegate respondsToSelector:@selector(BaseTabbarClickFentu)]) {
        [self.tabbarDelegate BaseTabbarClickFentu];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.hidden) {
        CGPoint getPoint = [self convertPoint:point toView:fentuBtn];
        if ([fentuBtn pointInside:getPoint withEvent:event]) {
            return fentuBtn;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

@end
