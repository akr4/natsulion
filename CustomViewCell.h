#import <Cocoa/Cocoa.h>

@interface CustomViewCell : NSCell {
    NSView *_view;
}

- (void) addView:(NSView*)view;

@end
