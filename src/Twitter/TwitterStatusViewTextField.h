#import <Cocoa/Cocoa.h>
#import "MessageViewTextField.h"
#import "TwitterStatus.h"

@interface TwitterStatusViewTextField : MessageViewTextField {
    TwitterStatus *_status;
}

- (void) setStatus:(TwitterStatus*)status;

- (NSString*) decodeEntityReferences:(NSString*)aString;
@end
