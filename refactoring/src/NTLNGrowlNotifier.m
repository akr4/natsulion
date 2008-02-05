#import <Growl/Growl.h>
#import "NTLNGrowlNotifier.h"

#define NTLN_NOTIFICATION_MESSAGE_RECEIVED @"Message Received"

@implementation NTLNGrowlNotifier

- (id) init {
    [GrowlApplicationBridge setGrowlDelegate:self];
    return self;
}

- (NSDictionary *) registrationDictionaryForGrowl {
    NSMutableDictionary *d = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    NSArray *notifications = [[[NSArray alloc] initWithObjects:NTLN_NOTIFICATION_MESSAGE_RECEIVED, nil] autorelease];
    [d setObject:notifications forKey:GROWL_NOTIFICATIONS_ALL];
    [d setObject:notifications forKey:GROWL_NOTIFICATIONS_DEFAULT];
    return d;
}

- (void) sendToGrowlTitle:(NSString*)title andDescription:(NSString*)description andIcon:(NSData*)iconData andPriority:(int)priority andSticky:(BOOL)sticky {
    [GrowlApplicationBridge
     notifyWithTitle:title
     description:description
     notificationName:NTLN_NOTIFICATION_MESSAGE_RECEIVED
     iconData:iconData
     priority:priority
     isSticky:sticky
     clickContext:nil];
}

@end
