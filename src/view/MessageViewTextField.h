#import <Cocoa/Cocoa.h>


@interface MessageViewTextField : NSTextField {
    NSColor *_defaultColor;
}

- (void) highlight;
- (void) unhighlight;

@end
