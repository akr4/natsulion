#import "NTLNMessage.h"
#import "NTLNAccount.h"
#import "NTLNURLUtils.h"

@implementation NTLNMessage

@synthesize statusId, name, screenName, text, icon, timestamp, replyType, status, user, inReplyToStatusId, inReplyToScreenName;

- (void) dealloc {
    [statusId release];
    [name release];
    [screenName release];
    [text release];
    [icon release];
    [timestamp release];
    [user release];
    [inReplyToStatusId release];
    [inReplyToScreenName release];
    [super dealloc];
}

- (BOOL) isEqual:(id)anObject {
    if ([[self statusId] isEqual:[anObject statusId]]) {
        return TRUE;
    }
    return FALSE;
}

- (void) setStatus:(enum NTLNMessageStatus)value {
    status = value;
}

- (BOOL) isReplyToMe {
    if ([[text lowercaseString] hasPrefix:[@"@" stringByAppendingString:[[[NTLNAccount instance] username] lowercaseString]]]) {
        //        NSLog(@"reply");
        return TRUE;
    }
    //    NSLog(@"not reply");
    return FALSE;
}

- (BOOL) isProbablyReplyToMe {
    NSString *query = [[@"@" stringByAppendingString:[[NTLNAccount instance] username]] lowercaseString];
    for (NSString *s in [[NTLNURLUtils utils] tokenizeByID:text]) {
        if ([[s lowercaseString] isEqualToString:query]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL) isMyUpdate {
    return [screenName isEqualToString:[[NTLNAccount instance] username]];
}

// determin type of message (DM is checked in Twitter.m)
- (void) finishedToSetProperties {
    if (replyType != 0) {
        // do nothing
    } else if ([self isMyUpdate]) {
        replyType = NTLN_MESSAGE_REPLY_TYPE_MYUPDATE;
    } else if ([self isReplyToMe]) {
        replyType = NTLN_MESSAGE_REPLY_TYPE_REPLY;
    } else if ([self isProbablyReplyToMe]) {
        replyType = NTLN_MESSAGE_REPLY_TYPE_REPLY_PROBABLE;
    } else {
        replyType = NTLN_MESSAGE_REPLY_TYPE_NORMAL;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"statusId:%@, name:%@, screenName:%@, text:%@, icon:%@, timestamp:%@",
            statusId, name, screenName, text, icon, timestamp];
}

@end
