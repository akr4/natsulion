#import <Cocoa/Cocoa.h>
#import "MessageViewController.h"
#import "MessageViewTimestampField.h"
#import "TwitterStatus.h"
#import "TwitterStatusViewNameField.h"
#import "TwitterStatusViewMessageField.h"
#import "TwitterStatusViewImageView.h"
#import "TwitterStatusView.h"

@protocol MessageViewListener;

@interface TwitterStatusViewController : MessageViewController {
    IBOutlet TwitterStatusView *view;
    IBOutlet TwitterStatusViewImageView *iconView;
    IBOutlet TwitterStatusViewMessageField *textField;
    IBOutlet TwitterStatusViewNameField *nameField;
    IBOutlet MessageViewTimestampField *timestampField;
    TwitterStatus *_status;
    
    NSObject<MessageViewListener> *_listener;
}

- (id) initWithTwitterStatus:(TwitterStatus*)status messageViewListener:(NSObject<MessageViewListener>*)listener;
- (TwitterStatus*) status;
- (BOOL) isEqual:(id)anObject;
- (void) highlight;
- (void) unhighlight;
- (NSView*) view;
- (float) requiredHeight;

// methods for subviews
- (void) iconViewClicked;

@end

