#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewTextField.h"

@interface NTLNMessageViewClickableTextField : NTLNMessageViewTextField {
    BOOL _mouseIsOnText;
}

- (BOOL) mouseIsOnText;
@end
