//
//  UITableViewController+SystemRefresh.h
//

#import <UIKit/UIKit.h>

@interface UITableViewController (SystemRefresh)
- (void)addHeaderRefreshAndHandle:(void(^)(__kindof UITableViewController *controller))handle;
- (void)endHeaderRefresh;
@end
