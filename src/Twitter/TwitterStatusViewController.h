#import <Cocoa/Cocoa.h>
#import "MessageViewController.h"
#import "TwitterStatus.h"
#import "TwitterStatusViewNameField.h"
#import "TwitterStatusViewMessageField.h"
#import "TwitterStatusViewTimestampField.h"
#import "TwitterStatusViewImageView.h"
#import "TwitterStatusView.h"

@protocol MessageViewListener;

@interface TwitterStatusViewController : MessageViewController {
    IBOutlet TwitterStatusView *view;
    IBOutlet TwitterStatusViewImageView *iconView;
    IBOutlet TwitterStatusViewMessageField *textField;
    IBOutlet TwitterStatusViewNameField *nameField;
    IBOutlet TwitterStatusViewTimestampField *timestampField;
    TwitterStatus *_status;
    
    NSObject<MessageViewListener> *_listener;
}

- (id) initWithTwitterStatus:(TwitterStatus*)status messageViewListener:(NSObject<MessageViewListener>*)listener;
- (BOOL) isEqual:(id)anObject;
- (void) highlight;
- (void) unhighlight;
- (NSView*) view;
- (float) requiredHeight;

@end

