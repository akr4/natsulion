#import "ErrorMessageViewController.h"


@implementation ErrorMessageViewController

- (id) initWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp {
    
    [super init];
    
    if (![NSBundle loadNibNamed: @"ErrorMessageView" owner: self]) {
        NSLog(@"unable to load Nib ErrorMessageView.nib");
    }
    
    [titleField setStringValue:title];
    [messageField setStringValue:message];
    [timestampField setTimestamp:timestamp];
    
    return self;
}

+ (id) controllerWithTitle:(NSString*)title message:(NSString*)message timestamp:(NSDate*)timestamp {
    return [[[ErrorMessageViewController alloc] initWithTitle:title message:message timestamp:timestamp] autorelease];
}

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

- (NSDate*) timestamp {
    return [timestampField timestamp];
}

@end
