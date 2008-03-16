#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewController.h"
#import "NTLNMessageViewTextField.h"
#import "NTLNMessageViewTimestampField.h"

@interface NTLNErrorMessageViewController : NTLNMessageViewController {
    IBOutlet NTLNMessageViewTextField *titleField;
    IBOutlet NTLNMessageViewTextField *messageField;
    IBOutlet NTLNMessageViewTimestampField *timestampField;
    IBOutlet NSView *messageView;
    
    NSString *_messageId;
    NSDate *_timestamp;
}

+ (id) controllerWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp;
- (id) initWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp;

@end
