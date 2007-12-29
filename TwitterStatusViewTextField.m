#import "TwitterStatusViewTextField.h"


@implementation TwitterStatusViewTextField

- (void) awakeFromNib {
    _defaultColor = [[self textColor] retain];
}

- (void) dealloc {
    [_defaultColor release];
    [super dealloc];
}

//- (void)mouseDown:(NSEvent *)theEvent {
//    NSLog(@"TwitterStatusViewTextField#mouseDown");
//    NSLog(@"=== %@ ---  %@", [self superview], [[self superview] superview]);
////    [[self superview] mouseDown:theEvent];
//    [super mouseDown:theEvent];
//}

- (void) highlight {
//    [self setTextColor:[NSColor selectedControlColor]];
    [self setTextColor:[NSColor whiteColor]];
}

- (void) lowlight {
    [self setTextColor:_defaultColor];
}

@end
