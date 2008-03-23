#import <Cocoa/Cocoa.h>
#import "NTLNMessage.h"

@class TwitterStatusViewController;

@interface TwitterStatusViewImageView : NSImageView {
    NTLNMessage *_status;
    TwitterStatusViewController *_controller;
}

- (void) highlight;
- (void) unhighlight;
- (void) setStatus:(NTLNMessage*)status;
- (void) setViewController:(TwitterStatusViewController*)controller;

@end
