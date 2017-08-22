//
//  UIScrollView+refresh.h
//

#import <UIKit/UIKit.h>

@interface UIScrollView (refresh)
- (void)addHeaderRefreshAndHandle:(void(^)(__kindof UIScrollView *superView))handle;
- (void)addFooterRefreshAndHandle:(void(^)(__kindof UIScrollView *superView))handle;
- (void)endHeaderRefresh;
- (void)endFooterRefresh;
- (void)noMoreData;
- (void)noMoreDataWithTip:(NSString*)tip;
- (void)resertNoMoreData;
- (void)begainHeadRefresh;
- (void)begainFooterRefresh;
@end
