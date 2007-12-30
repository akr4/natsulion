#import "TwitterStatusViewTextField.h"

@implementation TwitterStatusViewTextField

- (void) awakeFromNib {
    _defaultColor = [[self textColor] retain];
}

- (void) dealloc {
    [_defaultColor release];
    [super dealloc];
}

- (void) highlight {
//    [self setTextColor:[NSColor selectedControlColor]];
    [self setTextColor:[NSColor whiteColor]];
}

- (void) lowlight {
    [self setTextColor:_defaultColor];
}


@end
