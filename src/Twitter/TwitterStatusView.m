#import "TwitterStatusView.h"


@implementation TwitterStatusView

- (NSView *)hitTest:(NSPoint)aPoint {
    if (_highlighted) {
//        NSLog(@"hitTest: highlighted ----------------- %@", [textField description]);
        return [super hitTest:aPoint];
    }
    return self;
}

- (void) highlight {
    _highlighted = TRUE;
}

- (void) lowlight {
    _highlighted = FALSE;
}

@end
