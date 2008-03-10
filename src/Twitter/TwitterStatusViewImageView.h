#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"

@class TwitterStatusViewController;

@interface TwitterStatusViewImageView : NSImageView {
    TwitterStatus *_status;
    TwitterStatusViewController *_controller;
}

- (void) highlight;
- (void) unhighlight;
- (void) setStatus:(TwitterStatus*)status;
- (void) setViewController:(TwitterStatusViewController*)controller;

@end
