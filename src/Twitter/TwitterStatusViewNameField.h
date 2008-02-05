#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewClickableTextField.h"
#import "TwitterStatus.h"

@interface TwitterStatusViewNameField : NTLNMessageViewClickableTextField {
    TwitterStatus *_status;
}

- (void) setStatus:(TwitterStatus*)status;

@end
