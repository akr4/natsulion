#import <Cocoa/Cocoa.h>
#import "MessageViewController.h"
#import "MessageViewTimestampField.h"
#import "TwitterStatus.h"
#import "TwitterStatusViewNameField.h"
#import "TwitterStatusViewMessageField.h"
#import "TwitterStatusViewImageView.h"
#import "TwitterStatusView.h"

@interface TwitterStatusViewController : MessageViewController {
    IBOutlet TwitterStatusView *view;
    IBOutlet TwitterStatusViewImageView *iconView;
    IBOutlet TwitterStatusViewMessageField *textField;
    IBOutlet TwitterStatusViewNameField *nameField;
    IBOutlet MessageViewTimestampField *timestampField;
    TwitterStatus *_status;
}

- (id) initWithTwitterStatus:(TwitterStatus*)status;
- (TwitterStatus*) status;
- (BOOL) isEqual:(id)anObject;
- (void) highlight;
- (void) unhighlight;
- (NSView*) view;
- (float) requiredHeight;

@end

