#import <Cocoa/Cocoa.h>

@class NTLNMessage;

enum NTLNMessageInputTextFieldLengthState {
    NTLN_LENGTH_STATE_NORMAL,
    NTLN_LENGTH_STATE_WARNING,
    NTLN_LENGTH_STATE_MAXIMUM
};

@protocol NTLNMessageInputTextFieldCallback
- (void) messageInputTextFieldResized:(float)heightDelta;
- (void) messageInputTextFieldChanged:(int)length state:(enum NTLNMessageInputTextFieldLengthState)state;
@end

@interface NTLNMessageInputTextField : NSTextField {
    NSObject<NTLNMessageInputTextFieldCallback> *_callback;
    float _defaultHeight;
    NSColor *_backgroundColor;
    BOOL _frameSizeInternalChanging;
    int _warningLength;
    int _maxLength;
    enum NTLNMessageInputTextFieldLengthState _lengthState;
    NSCompositingOperation _backgroundCompositePolicy;
    BOOL _firstResponder;
}

- (void) setLengthForWarning:(int)warning max:(int)max;
- (void) setCallback:(NSObject<NTLNMessageInputTextFieldCallback>*)callback;
- (void) updateState;
- (void) focusAndLocateCursorEnd;

- (void) addReplyTo:(NTLNMessage*)message;
- (void) addDmReplyTo:(NTLNMessage*)message;
- (void) setRepostMessage:(NTLNMessage*)message;

@end
