#import <Cocoa/Cocoa.h>

@protocol AutoResizingTextFieldCallback
- (void) autoResizingTextFieldResized:(float)heightDelta;
@end

@interface AutoResizingTextField : NSTextField {
    NSObject<AutoResizingTextFieldCallback> *_callback;
    float _defaultHeight;
    BOOL _frameSizeInternalChanging;
}

- (void) setCallback:(NSObject<AutoResizingTextFieldCallback>*)callback;

@end
