//
//  FTWechatManager.m
//

#import "FTWechatManager.h"
#import <WXApi.h>
#import "MBProgressHUD+BL.h"

@implementation FTWechatManager

+ (void)shareUrlToWechat:(NSString *)url User:(NSString *)user Title:(NSString *)title Intro:(NSString *)intro avatar:(UIImage *)avatar type:(NSInteger)type
{
    [MBProgressHUD showMessage:@""];
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = [title stringByReplacingOccurrencesOfString:@"#分享者昵称#" withString:user];
    message.description = intro;
    [message setThumbImage:[self getThumbImage:avatar]];
    
    WXWebpageObject *webPageObject = [WXWebpageObject object];
    webPageObject.webpageUrl = url;
    
    message.mediaObject = webPageObject;
    
    SendMessageToWXReq *req = [SendMessageToWXReq new];
    req.bText = NO;
    req.message = message;
    req.scene = type == 1 ? WXSceneSession : WXSceneTimeline;
    
    [MBProgressHUD hideHUD];
    [WXApi sendReq:req];

}

+ (UIImage *)getThumbImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(150, 150), NO, 1);
    [image drawInRect:CGRectMake(0, 0, 150, 150)];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbImage;
}

@end
