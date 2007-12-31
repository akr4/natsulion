#import "TwitterUtils.h"


@implementation TwitterUtils

+ (id) utils {
    return [[[TwitterUtils alloc] init] autorelease];
}

- (NSString*) userPageURLString:(NSString*)screenName {
    NSMutableString *urlStr = [NSMutableString stringWithCapacity:20];
    [urlStr appendString:@"http://twitter.com/"];
    [urlStr appendString:screenName];
    return urlStr;
}
@end
