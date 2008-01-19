#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"
#import "TwitterStatusViewMessageField.h"

@class TwitterStatusViewController;

@interface TwitterStatusView : NSView {
    IBOutlet TwitterStatusViewMessageField *textField;
    
    TwitterStatus *_status;
    TwitterStatusViewController *_controller;
    
    BOOL _highlighted;
    NSColor *_backgroundColor;
    float _defaultHeight;
    float _requiredHeight;
    BOOL _sizeShouldBeCalculated;
}

- (void) setTwitterStatus:(TwitterStatus*)status;
- (void) highlight;
- (void) unhighlight;
- (float) requiredHeight;
- (void) markNeedCalculateHeight;
- (void) setViewController:(TwitterStatusViewController*)controller;

@end
