#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"

@interface TwitterStatusViewImageView : NSImageView {
    TwitterStatus *_status;
}

- (void) highlight;
- (void) unhighlight;
- (void) setStatus:(TwitterStatus*)status;

@end
