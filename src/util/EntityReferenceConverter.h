#import <Cocoa/Cocoa.h>

// TODO: change name to refrect its work. for example URL converter
@interface EntityReferenceConverter : NSObject {

}
+ (id) converter;

- (NSString*) dereference:(NSString*)aString;
- (NSString*) reference:(NSString*)aString;
@end
