//
//  NSString+BL.m
//

#import "NSString+BL.h"
#import <CommonCrypto/CommonDigest.h>
@implementation NSString (BL)
/**
 *  时间戳转化为正常时间
 *
 *  @return return value description
 */
-(NSString*)turnTimeWithTimestamp
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
    return [NSString stringWithFormat:@" %@",[formatter stringFromDate:date]];
}

+ (NSString *)turnTimeWithDate:(NSDate *)date{
    NSString *str = ({
         NSMutableString *mstr = @"".mutableCopy;
        NSDate *now = [NSDate date];
        NSTimeInterval interval = [date timeIntervalSinceDate:now] - 28800;
        
        interval = interval>0?interval:interval*(-1);
        if (interval <= 60*60){//一个小时内
            [mstr appendFormat:@"%.0f分钟",interval/60];
        }else if (interval <= 60*60*24) {//一天以内
            [mstr appendFormat:@"%.0f个小时",interval/(60*60)];
        }else if (interval <= (NSInteger)60*60*24*30){//一个月之内
            [mstr appendFormat:@"%.0f天",interval/(NSInteger)(60*60*24)];
        }else if (interval <= (NSInteger)60*60*24*30*12){//一年之内
            [mstr appendFormat:@"%.0f个月",interval/(NSInteger)(60*60*24*30)];
        }else {//超过一年
            [mstr appendFormat:@"%.0f年",interval/(NSInteger)(60*60*24*30*12)];
        }
        
        
        interval = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:now];
        now = [now dateByAddingTimeInterval:interval];
        NSComparisonResult result = [date compare:now];
        switch (result) {
            case NSOrderedSame:
                mstr = @"刚刚".mutableCopy;
                break;
            case NSOrderedAscending:
                [mstr appendString:@"前"];
                break;
            case NSOrderedDescending:
                [mstr appendString:@"后"];
                break;
            default:
                break;
        }
        str = mstr;
    });
    return str;
}

- (NSString *)timeStrWithFormatStr:(NSString*)format
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
    return [NSString stringWithFormat:@" %@",[formatter stringFromDate:date]];
}

/**
 *  时间转时间戳
 *
 *  @param date date description
 *
 *  @return return value description
 */
+ (NSString*)timestampWithDate:(NSDate*)date{
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate: date];
//    NSDate *localeDate = [date dateByAddingTimeInterval: interval];
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return timestamp;
}

- (NSString*)formatNumber{
    NSNumberFormatter *n2 = [[NSNumberFormatter alloc] init];
    [n2 setNumberStyle:1];
    return [n2 stringFromNumber:[NSNumber numberWithDouble:[self doubleValue]]];
}

/**
 *  base64 字符轉化為stirng
 *
 *  @param data base64 data
 *
 *  @return string
 */
+(NSString*)stringByTurnBase64string:(NSString*)base64
{
    if (base64) {
        NSData *data = [[NSData alloc]initWithBase64EncodedString:base64 options:0];
        return [[NSString alloc]initWithData:data encoding:(NSUTF8StringEncoding)];
    }
    return nil;
}

//URLEncode
- (NSString*)encodeString
{
    
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

//URLDEcode
-(NSString *)decodeString:(NSString*)encodedString

{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}


/**
 *  计算字符串长度
 *
 *  @param font 字体大小
 *
 *  @return 字符串长度
 */
- (CGSize)sizeWithFont:(UIFont *)font {
    
    return [self sizeWithFont:font maxW:MAXFLOAT];
}

- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW {
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    
    CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);
    
    return [self boundingRectWithSize:maxSize
                              options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:attrs
                              context:nil].size;
}

+ (NSString *)md5WithString:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)str.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}


/**
 *  是否为整型 NSInteger
 *
 *  @param string string description
 *
 *  @return return value description
 */
- (BOOL)isPureInteger
{
    
    NSScanner* scan = [NSScanner scannerWithString:self];
    
    NSInteger val;
    
    return[scan scanInteger:&val] && [scan isAtEnd];
    
}


/**
 *  是否为浮点型
 *
 *  @param string string description
 *
 *  @return return value description
 */
- (BOOL)isPureFloat
{
    
    NSScanner* scan = [NSScanner scannerWithString:self];
    
    float val;
    
    return[scan scanFloat:&val] && [scan isAtEnd];
    
}

/**
 *  "," " " "，" 自动换行
 */
- (NSString *)feedString
{
    NSString *text = self;
    text = [text stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"," withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"，" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"。" withString:@"\n"];

    return text;
}

//判断手机号码格式是否正确
+ (BOOL)valiMobile:(NSString *)mobile
{
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(17[5-6])|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}|((1349)|(1700))\\d{7}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
}

+ (BOOL)validateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (NSString *)convertUrl:(NSString *)urlStr WithWH:(NSString *)wh{
    if (![urlStr containsString:@"bmob-cdn-11098"]) {
        return urlStr;
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *path = url.path;
    if (wh) {
        path = [NSString stringWithFormat:@"%@?imageView2/1/w/%@/h/%@", path, wh, wh];
    }
    
    NSString *host = @"http://image.fentuapp.com.cn";
    
    return [NSString stringWithFormat:@"%@%@", host, path];
}

+ (NSString *)convertTime:(NSInteger)time {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"MM月dd日";
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}
@end
