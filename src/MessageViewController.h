#import <Cocoa/Cocoa.h>


@interface MessageViewController : NSObject {

}

- (void) highlight;
- (void) unhighlight;
- (NSView*) view;
- (float) requiredHeight;
- (NSDate*) timestamp;

@end
