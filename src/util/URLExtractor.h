#import <Cocoa/Cocoa.h>

#define NTLN_URLEXTRACTOR_PREFIX_HTTP @"http://"
#define NTLN_URLEXTRACTOR_PREFIX_ID @"@"

// TODO: this class should be renamed to reflect its work.
@interface URLExtractor : NSObject {

}
- (NSArray*) tokenizeByAll:(NSString*)aString;
- (NSArray*) tokenizeByURL:(NSString*)aString;
- (NSArray*) tokenizeByID:(NSString*)aString;
@end
