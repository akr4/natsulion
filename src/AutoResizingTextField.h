#import <Cocoa/Cocoa.h>

@protocol AutoResizingTextFieldCallback
- (void) autoResizingTextFieldResized:(float)heightDelta;
@end

enum NTLNLengthState {
    NTLN_LENGTH_STATE_NORMAL,
    NTLN_LENGTH_STATE_WARNING,
    NTLN_LENGTH_STATE_MAXIMUM
};

@interface AutoResizingTextField : NSTextField {
    NSObject<AutoResizingTextFieldCallback> *_callback;
    float _defaultHeight;
    NSColor *_defaultBackgroundColor;
    BOOL _frameSizeInternalChanging;
    int _warningLength;
    int _maxLength;
    enum NTLNLengthState _lengthState;
}

- (void) setLengthForWarning:(int)warning max:(int)max;
- (void) setCallback:(NSObject<AutoResizingTextFieldCallback>*)callback;
- (void) updateHeight;

@end
