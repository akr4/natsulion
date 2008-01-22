#import "TwitterStatus.h"
#import "PreferencesWindow.h"


@implementation TwitterStatus

- (BOOL) isReplyToMe {
    if ([text hasPrefix:[@"@" stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCE_USERID]]]) {
//        NSLog(@"reply");
        return TRUE;
    }
    //    NSLog(@"not reply");
    return FALSE;
}

- (BOOL) isProbablyReplyToMe {
    NSString *query = [@"@" stringByAppendingString:[[NSUserDefaults standardUserDefaults] stringForKey:PREFERENCE_USERID]];
    NSRange range = [text rangeOfString:query];
    
    if (range.location != NSNotFound) {
//        NSLog(@"probable reply");
        return TRUE;
    }
    //    NSLog(@"not reply");
    return FALSE;
}

- (void) finishedToSetProperties {
    if ([self isReplyToMe]) {
        replyType = MESSAGE_REPLY_TYPE_REPLY;
    } else if ([self isProbablyReplyToMe]) {
        replyType = MESSAGE_REPLY_TYPE_REPLY_PROBABLE;
    } else {
        replyType = MESSAGE_REPLY_TYPE_NORMAL;
    }
}

@end
