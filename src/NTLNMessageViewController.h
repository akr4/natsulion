#import <Cocoa/Cocoa.h>
#import "NTLNMessage.h"

@interface NTLNMessageViewController : NSObject {

}

#pragma mark Message accessors
- (NSString*) messageId;
- (NSDate*) timestamp;

#pragma mark
- (void) highlight;
- (void) unhighlight;
- (NSView*) view;
- (float) requiredHeight;
- (void) markNeedCalculateHeight;
- (void) enterInScrollView;
- (void) exitFromScrollView;
- (void) startAnimation;
- (void) stopAnimation;
- (void) markAsRead:(bool)notification;

#pragma mark methods for subclasses
- (void) iconViewClicked;
- (void) favoriteCreated;
- (void) favoriteCreationFailed;

@end
