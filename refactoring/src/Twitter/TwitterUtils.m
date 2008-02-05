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

- (NSString*) statusPageURLString:(NSString*)screenName statusId:(NSString*)statusId {
    NSMutableString *urlStr = [NSMutableString stringWithCapacity:20];
    [urlStr appendString:@"http://twitter.com/"];
    [urlStr appendString:screenName];
    [urlStr appendString:@"/statuses/"];
    [urlStr appendString:statusId];
    return urlStr;
}

@end
