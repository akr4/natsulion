#import "NTLNErrorMessageViewController.h"
#import "NTLNMessage.h"

@implementation NTLNErrorMessageViewController

- (id) initWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp {
    
    [super init];
    
    if (![NSBundle loadNibNamed: @"ErrorMessageView" owner: self]) {
        NSLog(@"unable to load Nib ErrorMessageView.nib");
    }
    
    [titleField setStringValue:title];
    [messageField setStringValue:message];
    [timestampField setTimestamp:timestamp];
    
    _message = [[NTLNMessage alloc] init];
    [_message setStatusId:@"a"]; // to be shown at the bottom
    [_message setTimestamp:timestamp];
    
    return self;
}

+ (id) controllerWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp {
    return [[[NTLNErrorMessageViewController alloc] initWithTitle:title message:message timestamp:timestamp] autorelease];
}

- (void) dealloc
{
    [_message release];
    [super dealloc];
}

#pragma mark Message accessors
- (NTLNMessage*) message
{
    return _message;
}

#pragma mark Message accessors
- (NSString*) messageId {
    return [_message statusId];
}
    
- (NSDate*) timestamp {
    return [_message timestamp];
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
