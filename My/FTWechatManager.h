//
//  FTWechatManager.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FTWechatManager : NSObject

+ (void)shareUrlToWechat:(NSString *)url User:(NSString *)user Title:(NSString *)title Intro:(NSString *)intro avatar:(UIImage *)avatar type:(NSInteger)type;

@end
