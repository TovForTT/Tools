//
//  NSString+BL.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSString (BL)
/**
 *  时间戳转标准时间字符串格式 yyyy/MM/dd
 *
 */
- (NSString *)turnTimeWithTimestamp;

/**
 *  时间戳转换为时间距离 格式为 X小时前 X天前 X月前 X年前
 *
 *
 *  @return return value description
 */
+ (NSString *)turnTimeWithDate:(NSDate *)date;

/**
 *  时间戳转换为 格式化时间
 *
 *  @param format 格式 "HH:MM"
 *
 *  @return return value description
 */
- (NSString *)timeStrWithFormatStr:(NSString*)format;
/**
 *  标准时间转时间戳
 *
 */
+ (NSString *)timestampWithDate:(NSDate*)date;



/**
 *  数字转换为货币计数显示
 *
 *  @return return value description
 */
- (NSString*)formatNumber;


/**
 *  是否为整型 NSInteger
 *
 *  @return return value description
 */
- (BOOL)isPureInteger;

/**
 *  是否为浮点型
 *
 *  @return return value description
 */
- (BOOL)isPureFloat;

/**
 *  计算字符串长度
 *  @param font 字体大小
 *
 *  @return 字符串长度
 */
- (CGSize)sizeWithFont:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;



/**
 *  base64 解码为字符
 *
 */
+ (NSString*)stringByTurnBase64string:(NSString*)data;

/**
 *  url encode
 *
 */
- (NSString*)encodeString;

/**
 *  url decode
 *
 */
- (NSString *)decodeString:(NSString*)encodedString;

/**
 *  md5加密
 *
 */
+ (NSString *)md5WithString:(NSString *)str;

/**
 *  "," " " "，" 自动换行
 */
- (NSString *)feedString;

//判断手机号码格式是否正确
+ (BOOL)valiMobile:(NSString *)mobile;
//邮箱
+ (BOOL)validateEmail:(NSString *)email;

+ (NSString *)convertUrl:(NSString *)urlStr WithWH:(NSString *)wh;

+ (NSString *)convertTime:(NSInteger)time;

@end
