#import <Cocoa/Cocoa.h>
#import "MessageViewTextField.h"

@interface MessageViewTimestampField : MessageViewTextField {
    NSDate *_timestamp;
}
- (void) setTimestamp:(NSDate*)timestamp;
- (NSDate*) timestamp;
@end
