#import <Growl/Growl.h>
#import "NTLNGrowlNotifier.h"

#define NTLN_GROWL_EVENT_MESSAGE_RECEIVED @"Message Received"
#define NTLN_GROWL_EVENT_REPLY_RECEIVED @"Reply Received"

@implementation NTLNGrowlNotifier

- (id) init {
    [GrowlApplicationBridge setGrowlDelegate:self];
    return self;
}

- (NSDictionary *) registrationDictionaryForGrowl {
    NSMutableDictionary *d = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    NSArray *notifications = [[[NSArray alloc] initWithObjects:NTLN_GROWL_EVENT_MESSAGE_RECEIVED, 
                               NTLN_GROWL_EVENT_REPLY_RECEIVED, nil] autorelease];
    [d setObject:notifications forKey:GROWL_NOTIFICATIONS_ALL];
    [d setObject:notifications forKey:GROWL_NOTIFICATIONS_DEFAULT];
    return d;
}

- (void) sendToGrowlTitle:(NSString*)title
              description:(NSString*)description
                replyType:(enum NTLNReplyType)type
                     icon:(NSData*)iconData {
    int priority = 0;
    BOOL sticky = FALSE;
    NSString *notificationName = NTLN_GROWL_EVENT_MESSAGE_RECEIVED;
    switch (type) {
        case MESSAGE_REPLY_TYPE_REPLY:
            priority = 2;
            sticky = TRUE;
            notificationName = NTLN_GROWL_EVENT_REPLY_RECEIVED;
            break;
        case MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
            priority = 1;
            sticky = TRUE;
            notificationName = NTLN_GROWL_EVENT_REPLY_RECEIVED;
            break;
        default:
            break;
    }
    
    [GrowlApplicationBridge
     notifyWithTitle:title
     description:description
     notificationName:notificationName
     iconData:iconData
     priority:priority
     isSticky:sticky
     clickContext:nil];
}

- (void) sendToGrowlTitle:(NSString*)title
              description:(NSString*)description
                replyType:(enum NTLNReplyType)type {
    [self sendToGrowlTitle:title description:description replyType:type icon:nil];
}

- (void) sendToGrowl:(NTLNMessage*)message {
    [self sendToGrowlTitle:[message name] description:[message text] replyType:[message replyType] icon:[[message icon] TIFFRepresentation]];
}

@end
