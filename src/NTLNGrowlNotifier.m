#import <Growl/Growl.h>
#import "NTLNGrowlNotifier.h"

#define NTLN_GROWL_EVENT_MESSAGE_RECEIVED @"Message Received"
#define NTLN_GROWL_EVENT_REPLY_RECEIVED @"Reply Received"

@implementation NTLNGrowlNotifier

- (id) init {
    [GrowlApplicationBridge setGrowlDelegate:self];
    return self;
}

- (void) dealloc
{
    [_callbackTarget release];
    [super dealloc];
}

- (void) setCallbackTarget:(NSObject<NTLNGrowlClickCallbackTarget>*)target
{
    _callbackTarget = target;
    [_callbackTarget retain];
}

- (NSDictionary *) registrationDictionaryForGrowl {
    NSMutableDictionary *d = [[[NSMutableDictionary alloc] initWithCapacity:10] autorelease];
    NSArray *notifications = [[[NSArray alloc] initWithObjects:NTLN_GROWL_EVENT_MESSAGE_RECEIVED, 
                               NTLN_GROWL_EVENT_REPLY_RECEIVED, nil] autorelease];
    [d setObject:notifications forKey:GROWL_NOTIFICATIONS_ALL];
    [d setObject:notifications forKey:GROWL_NOTIFICATIONS_DEFAULT];
    return d;
}

- (void) growlNotificationWasClicked:(id)clickContext
{
    NSString* statusId = clickContext;
    [_callbackTarget markAsRead:statusId];
}

- (void) sendToGrowlTitle:(NSString*)title
              description:(NSString*)description
                replyType:(enum NTLNReplyType)type
                     icon:(NSData*)iconData
                 statusId:(NSString*)statusId
{
    int priority = 0;
    BOOL sticky = FALSE;
    NSString *notificationName = NTLN_GROWL_EVENT_MESSAGE_RECEIVED;
    switch (type) {
        case NTLN_MESSAGE_REPLY_TYPE_REPLY:
            priority = 2;
            sticky = TRUE;
            notificationName = NTLN_GROWL_EVENT_REPLY_RECEIVED;
            break;
        case NTLN_MESSAGE_REPLY_TYPE_REPLY_PROBABLE:
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
     clickContext:statusId];
}

- (void) sendToGrowlTitle:(NSString*)title
              description:(NSString*)description
                replyType:(enum NTLNReplyType)type {
    [self sendToGrowlTitle:title description:description replyType:type icon:nil statusId:nil];
}

- (void) sendToGrowl:(NTLNMessage*)message {
    [self sendToGrowlTitle:[message name] 
               description:[message text]
                 replyType:[message replyType] 
                      icon:[[message icon] TIFFRepresentation]
                  statusId:[message statusId]];
}

@end
