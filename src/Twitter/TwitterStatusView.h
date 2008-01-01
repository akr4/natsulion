#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"
#import "TwitterStatusViewMessageField.h"

@interface TwitterStatusView : NSView {
    IBOutlet TwitterStatusViewMessageField *textField;

    TwitterStatus *_status;

    BOOL _highlighted;
    NSColor *_backgroundColor;
    float _defaultHeight;
    float _requiredHeight;
}

- (void) setTwitterStatus:(TwitterStatus*)status;
- (void) highlight;
- (void) unhighlight;
- (float) requiredHeight;

@end
