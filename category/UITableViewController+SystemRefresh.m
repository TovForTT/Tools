//
//  UITableViewController+SystemRefresh.m
//

#import "UITableViewController+SystemRefresh.h"
#import <UIControl+BlocksKit.h>
@implementation UITableViewController (SystemRefresh)

UIRefreshControl *refreshControl;

- (void)addHeaderRefreshAndHandle:(void(^)(__kindof UITableViewController *controller))handle{
    refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(handler) forControlEvents:UIControlEventValueChanged];
    [refreshControl bk_addEventHandler:^(id sender) {
        handle(self);
    } forControlEvents:(UIControlEventValueChanged)];
    [self setRefreshControl:refreshControl];
}

- (void)endHeaderRefresh{
    [refreshControl endRefreshing];
}
@end
