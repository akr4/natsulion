#import "EntityReferenceConverter.h"


@implementation EntityReferenceConverter

- (NSString*) dereference:(NSString*)aString {
    NSMutableString *back = [[aString mutableCopy] autorelease];
    [back replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, [back length])];
    [back replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [back length])];
    return back;
}

@end
