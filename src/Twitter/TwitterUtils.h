#import <Cocoa/Cocoa.h>


@interface TwitterUtils : NSObject {

}
+ (id) utils;
- (NSString*) userPageURLString:(NSString*)screenName;
@end
