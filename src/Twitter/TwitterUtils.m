#import "TwitterUtils.h"


@implementation TwitterUtils
- (NSString*) userPageURLString:(NSString*)screenName {
    NSMutableString *urlStr = [NSMutableString stringWithCapacity:20];
    [urlStr appendString:@"http://twitter.com/"];
    [urlStr appendString:screenName];
    return urlStr;
}
@end
