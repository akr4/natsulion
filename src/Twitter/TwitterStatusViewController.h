#import <Cocoa/Cocoa.h>
#import "NTLNMessageViewController.h"
#import "NTLNMessage.h"
#import "TwitterStatusViewNameField.h"
#import "TwitterStatusViewMessageField.h"
#import "TwitterStatusViewTimestampField.h"
#import "TwitterStatusViewImageView.h"
#import "TwitterStatusView.h"
#import "NTLNMessage.h"

@protocol NTLNMessageViewListener;

@interface TwitterStatusViewController : NTLNMessageViewController {
    IBOutlet TwitterStatusView *view;
    IBOutlet TwitterStatusViewImageView *iconView;
    IBOutlet TwitterStatusViewMessageField *textField;
    IBOutlet TwitterStatusViewNameField *nameField;
    IBOutlet TwitterStatusViewTimestampField *timestampField;
    IBOutlet NSButton *favoliteButton;
    IBOutlet NSImageView *newIconImageView;
    
    NTLNMessage *_status;
    
    NSObject<NTLNMessageViewListener> *_listener;
    BOOL _starHighlighted;
    BOOL _favoriteIsCreating;
    BOOL _highlighted;
    
    NSTimer *_markAsReadTimer;
}

- (IBAction) toggleFavorite:(id)sender;
- (IBAction) openReplyToMessage:(id)sender;

- (id) initWithTwitterStatus:(NTLNMessage*)status messageViewListener:(NSObject<NTLNMessageViewListener>*)listener;
- (BOOL) isEqual:(id)anObject;
- (void) showStar:(BOOL)show;
- (NTLNMessage*) message;
- (void) markAsRead;

@end

