#import <Cocoa/Cocoa.h>

@interface XMLHTTPEncoder : NSObject {

}
+ (id) encoder;

- (NSString*) decodeXML:(NSString*)aString;
- (NSString*) encodeHTTP:(NSString*)aString;
@end
