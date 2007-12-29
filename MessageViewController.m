#import "MessageViewController.h"


@implementation MessageViewController

- (void) dealloc {
    [_message release];
    [super dealloc];
}

- (void) highlight {
    
}

- (void) lowlight {
    
}

- (Message*) message {
    return _message;
}

- (void) setMessage:(Message*)message {
    _message = message;
    [_message retain];
}

- (NSView*) view {
    return view;
}

@end
