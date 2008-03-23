#import <Cocoa/Cocoa.h>
#import "NTLNMessage.h"
#import "TwitterStatusViewMessageField.h"

@class TwitterStatusViewController;

@interface TwitterStatusView : NSView {
    IBOutlet TwitterStatusViewMessageField *textField;
    
    NTLNMessage *_status;
    TwitterStatusViewController *_controller;
    
    BOOL _highlighted;
    NSColor *_backgroundColor;
    float _defaultHeight;
    float _requiredHeight;
    BOOL _sizeShouldBeCalculated;
    NSTimer *_starTimer;
}

- (void) setTwitterStatus:(NTLNMessage*)status;
- (void) highlight;
- (void) unhighlight;
- (float) requiredHeight;
- (void) markNeedCalculateHeight;
- (void) setViewController:(TwitterStatusViewController*)controller;

// for TwitterStatusViewController
- (NSColor*) backgroundColor;
- (void) colorSchemeChanged;

@end
