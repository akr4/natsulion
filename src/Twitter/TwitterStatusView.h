#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"
#import "TwitterStatusViewMessageField.h"

@interface TwitterStatusView : NSView {
    IBOutlet TwitterStatusViewMessageField *textField;

    BOOL _highlighted;
    NSColor *_backgroundColor;
    TwitterStatus *_status;
}

- (void) setTwitterStatus:(TwitterStatus*)status;
- (void) highlight;
- (void) lowlight;
    
@end
