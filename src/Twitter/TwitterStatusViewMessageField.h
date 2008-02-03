#import <Cocoa/Cocoa.h>
#import "MessageViewTextField.h"

@class TwitterStatusViewController;
@class TwitterStatusViewMessageField;

// this class is used for receiving mouseDown event
@interface TwitterStatusViewMessageTextView : NSTextView {
    TwitterStatusViewMessageField *_parent;
}
- (void) setParentView:(TwitterStatusViewMessageField*)parent;
@end

@interface TwitterStatusViewMessageField :  NSScrollView {
    IBOutlet TwitterStatusViewMessageTextView *textView;
    
    float _defaultHeight;
    float _defaultY;
    BOOL _highlighted;

    TwitterStatusViewController *_controller;
}

- (void) highlight;
- (void) unhighlight;
- (BOOL) highlighted;
- (void) setMessage:(NSString*)message;
- (float) expandIfNeeded;
- (void) setViewController:(TwitterStatusViewController*)controller;
- (TwitterStatusViewController*)controller;

@end
