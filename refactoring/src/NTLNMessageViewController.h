#import <Cocoa/Cocoa.h>
#import "NTLNMessage.h"

@interface NTLNMessageViewController : NSObject {

}

- (void) highlight;
- (void) unhighlight;
- (NSView*) view;
- (NTLNMessage*) message;
- (float) requiredHeight;
- (void) markNeedCalculateHeight;
- (NSDate*) timestamp;

// methods for subviews
- (void) iconViewClicked;
- (void) favoriteCreated;
- (void) favoriteCreationFailed;

@end
