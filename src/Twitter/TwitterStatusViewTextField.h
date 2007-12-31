#import <Cocoa/Cocoa.h>
#import "TwitterStatus.h"

@interface TwitterStatusViewTextField : NSTextField {
    NSColor *_defaultColor;
    TwitterStatus *_status;
}

- (void) highlight;
- (void) lowlight;
- (void) setStatus:(TwitterStatus*)status;

- (NSString*) decodeEntityReferences:(NSString*)aString;
@end
