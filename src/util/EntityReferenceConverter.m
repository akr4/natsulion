#import "EntityReferenceConverter.h"


@implementation EntityReferenceConverter

+ (id) converter {
    return [[[EntityReferenceConverter alloc] init] autorelease];
}

- (NSString*) dereference:(NSString*)aString {
    return (NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)aString, NULL, kCFStringEncodingUTF8);
}

- (NSString*) reference:(NSString*)aString {
    NSString *s = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aString, NULL, NULL, kCFStringEncodingUTF8);
    NSMutableString *back = [[s mutableCopy] autorelease];
    [back replaceOccurrencesOfString:@"&" withString:@"%26" options:0 range:NSMakeRange(0, [back length])];
    return back;
}

@end
