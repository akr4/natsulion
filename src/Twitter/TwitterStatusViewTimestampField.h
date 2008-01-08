#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"
#import "MessageViewTimestampField.h"

@interface TwitterStatusViewTimestampField : MessageViewTimestampField {
    TwitterStatus *_status;
}

- (void) setStatus:(TwitterStatus*)status;

@end
