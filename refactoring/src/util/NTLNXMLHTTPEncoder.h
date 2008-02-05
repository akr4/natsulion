#import <Cocoa/Cocoa.h>

@interface NTLNXMLHTTPEncoder : NSObject {

}
+ (id) encoder;

- (NSString*) decodeXML:(NSString*)aString;
- (NSString*) encodeHTTP:(NSString*)aString;
@end
