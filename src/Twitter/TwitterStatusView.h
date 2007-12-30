#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"
#import "TwitterStatusViewTextField.h"

@interface TwitterStatusView : NSView {
    IBOutlet TwitterStatusViewTextField *textField;

    BOOL _highlighted;
    NSColor *_backgroundColor;
    TwitterStatus *_status;
}

- (void) setTwitterStatus:(TwitterStatus*)status;
- (void) highlight;
- (void) lowlight;
    
@end
