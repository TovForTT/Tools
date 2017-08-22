//
//  TempManger.h
//

#import <Foundation/Foundation.h>

@interface TempManger : NSObject
+ (BOOL)plistCacheWithPlistName:(NSString*)name content:(id)content;
+ (NSDictionary*)dictWithPlistName:(NSString*)name;
+ (NSArray*)arrayWithPlistName:(NSString*)name;

+ (BOOL)archivedDataWithObject:(id)object name:(NSString*)name;
+ (id)unarchiveDataWithName:(NSString*)name;
@end
