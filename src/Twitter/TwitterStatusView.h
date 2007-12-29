#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"
#import "TwitterStatusViewTextField.h"

static NSColor *_viewBackgroundColorReply;
static NSColor *_viewHighlightedBackgroundColorReply;
static NSColor *_viewBackgroundColorReplyProbable;
static NSColor *_viewHighlightedBackgroundColorReplyProbable;

@interface TwitterStatusView : NSView {
    IBOutlet TwitterStatusViewTextField *textField;

    BOOL _highlighted;
    NSColor *_backgroundColor;
    TwitterStatus *_status;
}

- (void) setTwitterStatus:(TwitterStatus*)status;
- (void) highlight;
- (void) lowlight;
    
@end
