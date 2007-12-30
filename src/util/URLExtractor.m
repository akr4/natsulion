#import "URLExtractor.h"

@implementation URLExtractor

- (NSArray*) tokenize:(NSString*)aString {

    NSCharacterSet *URL_ACCEPTED_CHARS = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789;/?:@&=+$,-_.!~*'()%"];
    
    NSMutableArray *back = [NSMutableArray arrayWithCapacity:10];

    NSRange httpRange = [aString rangeOfString:URLEXTRACTOR_PROTOCOL_HEAD_HTTP];
    if (httpRange.location == NSNotFound) {
        if ([aString length] > 0) {
            [back addObject:aString];
        }
        return back;
    }

    if (httpRange.location > 0) {
        [back addObject:[aString substringWithRange:NSMakeRange(0, httpRange.location)]];
    }

    NSRange searchRange = NSMakeRange(httpRange.location, 1);
    while (searchRange.location < [aString length]) {
        NSRange r = [aString rangeOfCharacterFromSet:URL_ACCEPTED_CHARS options:0 range:searchRange];
        if (r.location == NSNotFound) {
            break;
        }
        searchRange.location += r.length;
    }
    
    NSRange urlRange = NSMakeRange(httpRange.location, searchRange.location - httpRange.location);
    NSLog(@"URL: %@", [aString substringWithRange:urlRange]);
    [back addObject:[aString substringWithRange:urlRange]];
    
    NSArray *subBack = [self tokenize:[aString substringWithRange:
                    NSMakeRange(urlRange.location + urlRange.length, [aString length] - (urlRange.location + urlRange.length))]];
    
    [back addObjectsFromArray:subBack];
    
    return back;
}
@end
