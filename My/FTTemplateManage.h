//
//  FTTemplateManage.h
//

#import <Foundation/Foundation.h>
#import "TemplateModel.h"
@interface FTTemplateManage : NSObject

@property (nonatomic, copy) void (^loadbBlock) (BOOL isSuccess);

@property (nonatomic, copy) NSString *shareUrl;

+ (instancetype)templateManageWithModel:(TemplateModel *)model;

- (void)loadTemplate;
- (NSArray<UIImage *> *)formatTemplateImages;
@end
