//
//  FTNetWorking.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FTNetWorking : NSObject


+ (void)Get:(NSString *)url parmeters:(NSDictionary *)parmeters success:(void(^) (id responseObject))success failure:(void (^) (NSError *error))failure;

+ (void)Post:(NSString *)url parmeters:(NSDictionary *)parmeters success:(void(^) (id responseObject))success failure:(void (^) (NSError *error))failure;

+ (void)uploadFile:(NSString *)url fileName:(NSString *)fileName imageData:(NSData *)imageData success:(void(^) (id responseObject))success failure:(void (^) (NSError *error))failure;

+ (void)getIcon:(NSString *)url Icon:(void (^) (UIImage *icon))handle;

@end
