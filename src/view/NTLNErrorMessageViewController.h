#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewController.h"
#import "NTLNMessageViewTextField.h"
#import "NTLNMessageViewTimestampField.h"

@class NTLNMessage;

@interface NTLNErrorMessageViewController : NTLNMessageViewController {
    IBOutlet NTLNMessageViewTextField *titleField;
    IBOutlet NTLNMessageViewTextField *messageField;
    IBOutlet NTLNMessageViewTimestampField *timestampField;
    IBOutlet NSView *messageView;
    
    NTLNMessage *_message;
}

+ (id) controllerWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp;
- (id) initWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp;
- (NTLNMessage*) message;
- (NSString*) messageId;
- (NSDate*) timestamp;
    
@end
