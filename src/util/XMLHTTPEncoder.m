#import "XMLHTTPEncoder.h"


@implementation XMLHTTPEncoder

+ (id) encoder {
    return [[[XMLHTTPEncoder alloc] init] autorelease];
}

- (NSString*) urlencode:(NSString*)aString {
    NSString *escaped = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aString, NULL, NULL, kCFStringEncodingUTF8);
    NSMutableString *s = [[escaped mutableCopy] autorelease];
    [s replaceOccurrencesOfString:@"&" withString:@"%26" options:0 range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"?" withString:@"%3F" options:0 range:NSMakeRange(0, [s length])];
    return s;
}

//- (NSString*) urldecode:(NSString*)aString {
//    return (NSString*)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)aString, NULL, kCFStringEncodingUTF8);
//}

- (NSString*) dereference:(NSString*)aString {
    NSMutableString *s = [[aString mutableCopy] autorelease];
    [s replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [s length])];
    return s;
}

- (NSString*) encodeHTTP:(NSString*)aString {
    return [self urlencode:aString];
}

- (NSString*) decodeXML:(NSString*)aString {
    return [self dereference:aString];
}

@end
