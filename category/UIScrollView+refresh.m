//
//  UIScrollView+refresh.m
//

#import "UIScrollView+refresh.h"
#import "MJRefresh.h"

@implementation UIScrollView (refresh)

- (void)addHeaderRefreshAndHandle:(void(^)(__kindof UIScrollView *superView))handle
{
    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (handle) {
            handle(self);
        }
    }];
}

- (void)addFooterRefreshAndHandle:(void(^)(__kindof UIScrollView *superView))handle
{
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (handle) {
            handle(self);
        }
    }];
    footer.stateLabel.hidden = NO;
    footer.stateLabel.font = [UIFont systemFontOfSize:12];
//    footer.stateLabel.textColor = [UIColor whiteColor];
//    footer.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.mj_footer = footer;
}

- (void)endFooterRefresh
{
    [self.mj_footer endRefreshing];
}
- (void)endHeaderRefresh
{
    [self.mj_header endRefreshing];
}
- (void)noMoreData
{
    [self.mj_footer endRefreshingWithNoMoreData];
}
- (void)noMoreDataWithTip:(NSString*)tip
{
    MJRefreshBackNormalFooter *footer = (MJRefreshBackNormalFooter *)self.mj_footer;
    [footer setTitle:tip forState:(MJRefreshStateNoMoreData)];
    footer.stateLabel.hidden = NO;
    footer.stateLabel.font = [UIFont systemFontOfSize:12];
//    footer.stateLabel.textColor = [UIColor whiteColor];
    
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)resertNoMoreData{
    [self.mj_footer resetNoMoreData];
}

- (void)begainHeadRefresh {
    [self.mj_header beginRefreshing];
}

- (void)begainFooterRefresh {
    [self.mj_footer beginRefreshing];
}

@end
