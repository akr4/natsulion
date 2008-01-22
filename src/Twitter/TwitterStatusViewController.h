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
    IBOutlet NSButton *favoliteButton;
    TwitterStatus *_status;
    
    NSObject<MessageViewListener> *_listener;
    BOOL _starHighlighted;
    BOOL _favoriteIsCreating;
}

- (IBAction) toggleFavorite:(id)sender;

- (id) initWithTwitterStatus:(TwitterStatus*)status messageViewListener:(NSObject<MessageViewListener>*)listener;
- (BOOL) isEqual:(id)anObject;
- (void) showStar:(BOOL)show;

@end

