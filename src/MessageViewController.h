#import <Cocoa/Cocoa.h>
#import "Message.h"

@interface MessageViewController : NSObject {

}

- (void) highlight;
- (void) unhighlight;
- (NSView*) view;
- (Message*) message;
- (float) requiredHeight;
- (void) markNeedCalculateHeight;
- (NSDate*) timestamp;

// methods for subviews
- (void) iconViewClicked;
- (void) favoriteCreated;
- (void) favoriteCreationFailed;

@end
