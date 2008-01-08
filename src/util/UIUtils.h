#import <Cocoa/Cocoa.h>


@interface UIUtils : NSObject {

}

+ (id) utils;

- (float) heightForString:(NSString*)myString font:(NSFont*)myFont width:(float)myWidth;
- (float) widthForString:(NSString*)myString font:(NSFont*)myFont height:(float)myHeight;

@end
