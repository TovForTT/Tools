//
//  FTImageEditViewController.h
//

#import "BaseViewController.h"
#import "TemplateModel.h"
#import "EditOperateView.h"
@interface FTImageEditViewController : BaseViewController
@property (nonatomic, strong) TemplateModel *model;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) BOOL isChangeType;
@property (nonatomic, assign) EditType editType;

@end
