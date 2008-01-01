#import "MessageViewTextField.h"


@implementation MessageViewTextField

- (void) dealloc {
    [_defaultColor release];
    [super dealloc];
}

- (void) awakeFromNib {
    _defaultColor = [[self textColor] retain];
}

- (void) highlight {
    [self setTextColor:[NSColor whiteColor]];
}

- (void) unhighlight {
    [self setTextColor:_defaultColor];
}

@end
