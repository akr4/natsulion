#import "TwitterStatusViewController.h"


@implementation TwitterStatusViewController

- (id) initWithTwitterStatus:(TwitterStatus*)status {
    [super init];

    _status = status;
    [_status retain];
    
    if (![NSBundle loadNibNamed: @"TwitterStatusView" owner: self]) {
        NSLog(@"unable to load Nib TwitterStatusView.nib");
    }
    [textField setMessage:[status text]];
    [nameField setStatus:_status];
    [iconView setStatus:_status];
    [timestampField setTimestamp:[status timestamp]];
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

@end
