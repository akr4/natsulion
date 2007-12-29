#import <Cocoa/Cocoa.h>


@interface TwitterStatusViewTextField : NSTextField {
    NSColor *_defaultColor;
}

- (void) highlight;
- (void) lowlight;

@end
