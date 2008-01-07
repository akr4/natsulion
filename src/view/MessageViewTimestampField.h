#import <Cocoa/Cocoa.h>
#import "MessageViewClickableTextField.h"

@interface MessageViewTimestampField : MessageViewClickableTextField {
    NSDate *_timestamp;
}
- (void) setTimestamp:(NSDate*)timestamp;
- (NSDate*) timestamp;
@end
