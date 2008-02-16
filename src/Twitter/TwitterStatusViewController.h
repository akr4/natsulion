#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewController.h"
#import "TwitterStatus.h"
#import "TwitterStatusViewNameField.h"
#import "TwitterStatusViewMessageField.h"
#import "TwitterStatusViewTimestampField.h"
#import "TwitterStatusViewImageView.h"
#import "TwitterStatusView.h"

@protocol NTLNMessageViewListener;

@interface TwitterStatusViewController : NTLNMessageViewController {
    IBOutlet TwitterStatusView *view;
    IBOutlet TwitterStatusViewImageView *iconView;
    IBOutlet TwitterStatusViewMessageField *textField;
    IBOutlet TwitterStatusViewNameField *nameField;
    IBOutlet TwitterStatusViewTimestampField *timestampField;
    IBOutlet NSButton *favoliteButton;
    TwitterStatus *_status;
    
    NSObject<NTLNMessageViewListener> *_listener;
    BOOL _starHighlighted;
    BOOL _favoriteIsCreating;
    BOOL _highlighted;
}

- (IBAction) toggleFavorite:(id)sender;

- (id) initWithTwitterStatus:(TwitterStatus*)status messageViewListener:(NSObject<NTLNMessageViewListener>*)listener;
- (BOOL) isEqual:(id)anObject;
- (void) showStar:(BOOL)show;

@end

