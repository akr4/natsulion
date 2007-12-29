#import "TwitterStatusViewImageView.h"


@implementation TwitterStatusViewImageView

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"TwitterStatusViewImageView#mouseDown");
    [[self superview] mouseDown:theEvent];
}

- (void) highlight {
}

- (void) lowlight {
}

@end
