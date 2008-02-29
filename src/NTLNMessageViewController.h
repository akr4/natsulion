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
- (void) enterInScrollView;
- (void) exitFromScrollView;
- (void) startAnimation;
- (void) stopAnimation;
- (void) markAsRead:(bool)notification;

// methods for subviews
- (void) iconViewClicked;
- (void) favoriteCreated;
- (void) favoriteCreationFailed;

@end
