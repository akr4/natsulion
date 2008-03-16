#import "TwitterStatus.h"
#import "NTLNPreferencesWindowController.h"
#import "NTLNAccount.h"

@implementation TwitterStatus

- (BOOL) isReplyToMe {
    if ([text hasPrefix:[@"@" stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:NTLN_PREFERENCE_USERID]]]) {
//        NSLog(@"reply");
        return TRUE;
    }
    //    NSLog(@"not reply");
    return FALSE;
}

- (BOOL) isProbablyReplyToMe {
    NSString *query = [@"@" stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:NTLN_PREFERENCE_USERID]];
    NSRange range = [text rangeOfString:query];
    
    if (range.location != NSNotFound) {
//        NSLog(@"probable reply");
        return TRUE;
    }
    //    NSLog(@"not reply");
    return FALSE;
}

- (BOOL) isMyUpdate {
    return [screenName isEqualToString:[[NTLNAccount instance] username]];
}

- (void) finishedToSetProperties {
    if ([self isMyUpdate]) {
        replyType = NTLN_MESSAGE_REPLY_TYPE_MYUPDATE;
    } else if ([self isReplyToMe]) {
        replyType = NTLN_MESSAGE_REPLY_TYPE_REPLY;
    } else if ([self isProbablyReplyToMe]) {
        replyType = NTLN_MESSAGE_REPLY_TYPE_REPLY_PROBABLE;
    } else {
        replyType = NTLN_MESSAGE_REPLY_TYPE_NORMAL;
    }
}

@end
