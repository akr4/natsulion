#import "NTLNErrorMessageViewController.h"

static long messageCounter;

@implementation NTLNErrorMessageViewController

- (id) initWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp {
    
    [super init];
    
    if (![NSBundle loadNibNamed: @"ErrorMessageView" owner: self]) {
        NSLog(@"unable to load Nib ErrorMessageView.nib");
    }
    
    [titleField setStringValue:title];
    [messageField setStringValue:message];
    [timestampField setTimestamp:timestamp];
    
    _messageId = [NSString stringWithFormat:@"error-%ld", messageCounter++];
    _timestamp = timestamp;
    
    return self;
}

+ (id) controllerWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp {
    return [[[NTLNErrorMessageViewController alloc] initWithTitle:title message:message timestamp:timestamp] autorelease];
}

#pragma mark Message accessors
- (NSString*) messageId {
    return _messageId;
}

- (NSDate*) timestamp {
    return _timestamp;
}

#pragma mark
- (void) highlight {
    [titleField highlight];
    [messageField highlight];
    [timestampField highlight];
}

- (void) unhighlight {
    [titleField unhighlight];
    [messageField unhighlight];
    [timestampField unhighlight];
}

- (NSView*) view {
    return messageView;
}

- (float) requiredHeight {
    return [messageView frame].size.height;
}

@end
