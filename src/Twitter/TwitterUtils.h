#import <Cocoa/Cocoa.h>


@interface TwitterUtils : NSObject {

}
+ (id) utils;
- (NSString*) userPageURLString:(NSString*)screenName;
- (NSString*) statusPageURLString:(NSString*)screenName statusId:(NSString*)statusId;
@end
