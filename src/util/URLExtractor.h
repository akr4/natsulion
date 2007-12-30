#import <Cocoa/Cocoa.h>

#define URLEXTRACTOR_PROTOCOL_HEAD_HTTP @"http://"

@interface URLExtractor : NSObject {

}
- (NSArray*) tokenize:(NSString*)aString;
@end
