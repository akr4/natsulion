#import "TwitterStatusViewController.h"
#import "MainWindowController.h"

@implementation TwitterStatusViewController

- (id) initWithTwitterStatus:(TwitterStatus*)status messageViewListener:(NSObject<MessageViewListener>*)listener {
    [super init];

    _status = status;
    [_status retain];
    
    _listener = listener;
    [_listener retain];
    
    if (![NSBundle loadNibNamed: @"TwitterStatusView" owner: self]) {
        NSLog(@"unable to load Nib TwitterStatusView.nib");
    }
    [textField setMessage:[status text]];
    [nameField setStatus:_status];
    [timestampField setStatus:_status];
    [iconView setStatus:_status];
    [iconView setViewController:self];
    [view setTwitterStatus:_status];

    return self;
}

- (TwitterStatus*) status {
    return _status;
}

- (NSView*) view {
    return view;
}

- (void) dealloc {
    [_status release];
    [_listener release];
    [textField removeFromSuperview];
    [nameField removeFromSuperview];
    [iconView removeFromSuperview];
    [timestampField removeFromSuperview];
    [view removeFromSuperview];
    [view release];
    [super dealloc];
}

- (NSTextField*) nameField {
    return nameField;
}

- (BOOL) isEqual:(id)anObject {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
	if (anObject == self)
        return TRUE;
	if (!anObject || ![anObject isKindOfClass:[self class]])
        return FALSE;
    return [[self status] isEqual:[(TwitterStatusViewController*)anObject status]];
}
     
- (void) highlight {
    [view highlight];
    [textField highlight];
    [nameField highlight];
    [timestampField highlight];
    [iconView highlight];
}

- (void) unhighlight {
    [view unhighlight];
    [textField unhighlight];
    [nameField unhighlight];
    [timestampField unhighlight];
    [iconView unhighlight];
}

- (float) requiredHeight {
    return [view requiredHeight];
}

- (NSDate*) timestamp {
    return [_status timestamp];
}

- (void) iconViewClicked {
    [_listener replyDesiredFor:[_status screenName]];
}

@end
