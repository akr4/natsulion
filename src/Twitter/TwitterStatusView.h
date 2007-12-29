#import <Cocoa/Cocoa.h>
#import "TwitterStatusViewTextField.H"

@interface TwitterStatusView : NSView {
    IBOutlet TwitterStatusViewTextField *textField;

    BOOL _highlighted;
}

@end
