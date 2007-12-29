#import <Cocoa/Cocoa.h>
#import "Message.h"

@interface MessageViewController : NSObject {


    Message *_message;
}

// sub classes must implement
- (void) highlight;
- (void) lowlight;
- (Message*) message;
- (void) setMessage:(Message*)message;

@end
