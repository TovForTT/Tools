//
//  FTNetWorking.m
//

#import "FTNetWorking.h"
#import <AFNetworking.h>
#import "NSString+BL.h"
#import "MBProgressHUD+BL.h"
#import "UIImageView+YYWebImage.h"

@implementation FTNetWorking


+ (void)Get:(NSString *)url parmeters:(NSDictionary *)parmeters success:(void(^) (id))success failure:(void (^) (NSError *))failure {
//    if ([url containsString:@"api.fentuapp.com.cn"]) {
//        url = [url stringByReplacingOccurrencesOfString:@"http://api.fentuapp.com.cn" withString:@"http://192.168.1.167/fentu_server/public"];
//    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = nil;
    [manager GET:url parameters:parmeters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        if ([responseObject[@"errcode"] integerValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showText:responseObject[@"errstr"]];
            });
        }
        success(responseObject);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (failure) {
            failure(error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showText:@"网络异常"];
        });
    }];
}

+ (void)Post:(NSString *)url parmeters:(NSDictionary *)parmeters success:(void (^)(id))success failure:(void (^)(NSError *))failure {
//    if ([url containsString:@"api.fentuapp.com.cn"]) {
//        url = [url stringByReplacingOccurrencesOfString:@"http://api.fentuapp.com.cn" withString:@"http://192.168.1.167/fentu_server/public"];
//    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *key = @"MIIEvQIBADANBgkqhkiG9w0B";
    NSString *random = [self randomStringWithLength:8];
    NSString *time = [NSString timestampWithDate:[NSDate date]];
    
    NSString *sign = [NSString md5WithString:[[NSString stringWithFormat:@"%@%@%@",time,key,random] uppercaseString]];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"]; // 设置content-Type为text/html
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    [manager.requestSerializer setValue:time forHTTPHeaderField:@"t"];
    [manager.requestSerializer setValue:random forHTTPHeaderField:@"s"];
    [manager.requestSerializer setValue:sign forHTTPHeaderField:@"sign"];

    
    [manager POST:url parameters:parmeters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        if ([responseObject[@"errcode"] integerValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showText:responseObject[@"errstr"]];
            });
        }
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        if (failure) {
            failure(error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showText:@"网络异常"];
        });
    }];
}

+ (NSString *)randomStringWithLength:(NSInteger)len {
    NSString *letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString;
}

+ (void)uploadFile:(NSString *)url fileName:(NSString *)fileName imageData:(NSData *)imageData success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData
                                    name:@"file"
                                fileName:fileName
                                mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
        if ([responseObject[@"errcode"] integerValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showText:responseObject[@"errstr"]];
            });
        } else {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
            [MBProgressHUD showText:@"网络异常"];
        });
    }];
}

+ (void)getIcon:(NSString *)url Icon:(void (^)(UIImage *))handle {
    __block UIImage *icon = [[YYImageCache sharedCache] getImageForKey:url];
    if (!icon) {
        [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:url] options:0 progress:nil transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            handle(image);
        }];
    } else {
        handle(icon);
    }
}

@end
