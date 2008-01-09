#import <Cocoa/Cocoa.h>
#import "MessageViewTextField.h"

@interface MessageViewClickableTextField : MessageViewTextField {
    BOOL _mouseIsOnText;
}

- (BOOL) mouseIsOnText;
@end
