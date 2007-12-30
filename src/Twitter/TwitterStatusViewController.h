#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"
#import "TwitterStatusViewTextField.h"
#import "TwitterStatusViewMessageField.h"
#import "TwitterStatusViewImageView.h"
#import "TwitterStatusView.h"

@interface TwitterStatusViewController : NSObject {
    IBOutlet TwitterStatusView *view;
    IBOutlet TwitterStatusViewImageView *iconView;
    IBOutlet TwitterStatusViewMessageField *textField;
    IBOutlet TwitterStatusViewTextField *nameField;
    IBOutlet TwitterStatusViewTextField *timestampField;
    TwitterStatus *_status;
}

- (id) initWithTwitterStatus:(TwitterStatus*)status;
- (TwitterStatus*) status;
- (BOOL) isEqual:(id)anObject;
- (void) highlight;
- (void) lowlight;
- (NSView*) view;

@end

