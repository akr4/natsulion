#import <Cocoa/Cocoa.h>

enum NTLNMessageInputTextFieldLengthState {
    NTLN_LENGTH_STATE_NORMAL,
    NTLN_LENGTH_STATE_WARNING,
    NTLN_LENGTH_STATE_MAXIMUM
};

@protocol MessageInputTextFieldCallback
- (void) messageInputTextFieldResized:(float)heightDelta;
- (void) messageInputTextFieldChanged:(int)length state:(enum NTLNMessageInputTextFieldLengthState)state;
@end

@interface MessageInputTextField : NSTextField {
    NSObject<MessageInputTextFieldCallback> *_callback;
    float _defaultHeight;
    NSColor *_defaultBackgroundColor;
    BOOL _frameSizeInternalChanging;
    int _warningLength;
    int _maxLength;
    enum NTLNMessageInputTextFieldLengthState _lengthState;
}

- (void) setLengthForWarning:(int)warning max:(int)max;
- (void) setCallback:(NSObject< MessageInputTextFieldCallback>*)callback;
- (void) updateHeight;

@end
