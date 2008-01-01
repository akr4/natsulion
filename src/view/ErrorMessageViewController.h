#import <Cocoa/Cocoa.h>
#import "MessageViewController.h"
#import "MessageViewTextField.h"
#import "MessageViewTimestampField.h"

@interface ErrorMessageViewController : MessageViewController {
    IBOutlet MessageViewTextField *titleField;
    IBOutlet MessageViewTextField *messageField;
    IBOutlet MessageViewTimestampField *timestampField;
    IBOutlet NSView *messageView;
}

+ (id) controllerWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp;
- (id) initWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp;

@end
