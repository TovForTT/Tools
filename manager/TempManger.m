//
//  TempManger.m
//
#define kTempPath(name,postfix) [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.%@",name,postfix]]
#import "TempManger.h"

@implementation TempManger
+ (BOOL)plistCacheWithPlistName:(NSString*)name content:(id)content
{
    if (!content) {
        return NO;
    }else{
        BOOL falg =  [content writeToFile:kTempPath(name, @"plist") atomically:YES];
        return falg;
        
    }
}
+ (NSDictionary*)dictWithPlistName:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *dict = nil;
    if ([fileManager fileExistsAtPath:kTempPath(name, @"plist")]) {
        dict = [NSDictionary dictionaryWithContentsOfFile:kTempPath(name, @"plist")];
    }
    return dict;
    
}
+ (NSArray*)arrayWithPlistName:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = nil;
    if ([fileManager fileExistsAtPath:kTempPath(name, @"plist")]) {
        array = [NSArray arrayWithContentsOfFile:kTempPath(name, @"plist")];
    }
    return array;
}

+ (BOOL)archivedDataWithObject:(id)object name:(NSString*)name
{
    if (!object) {
        return NO;
    }
    BOOL falg = [NSKeyedArchiver archiveRootObject:object toFile:kTempPath(name, @"plist")];
    return falg;
}

+ (id)unarchiveDataWithName:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:kTempPath(name, @"plist")]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:kTempPath(name, @"plist")];
    }
    return nil;
}
@end
