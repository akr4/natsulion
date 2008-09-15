#import "Twitter.h"
#import "NTLNConfiguration.h"
#import "NTLNXMLHTTPEncoder.h"

#define API_BASE @"http://twitter.com"

@implementation NTLNErrorInfo
+ (id) infoWithType:(enum NTLNErrorType)type originalMessage:(NSString*)message {
    NTLNErrorInfo *info = [[[NTLNErrorInfo alloc] init] autorelease];
    [info setType:type];
    [info setOriginalMessage:message];
    return info;
}

- (enum NTLNErrorType)type {
    return _type;
}

- (void) setType:(enum NTLNErrorType)type {
    _type = type;
}

- (NSString*)originalMessage {
    return _originalMessage;
}

- (void) setOriginalMessage:(NSString*)message {
    _originalMessage = message;
    [_originalMessage retain];
}

- (void) dealloc {
    [_originalMessage release];
    [super dealloc];
}
@end

@implementation TwitterTimelineCallbackHandler

- (NSString*) convertToLargeIconUrl:(NSString*)url {
    return url;
    
    //    // [@"_normal.jpg" length] = 11
    //    int loc = [url length] - 11;
    //    NSRange normalSuffixRange;
    //    normalSuffixRange.location = loc;
    //    normalSuffixRange.length = 7; // "_normal"
    //    NSString *suffix = [url substringWithRange:normalSuffixRange];
    //    if ([suffix isEqualToString:@"_normal"]) {
    //        NSMutableString *u = [url mutableCopy];
    //        NSRange r;
    //        r.location = loc;
    //        r.length = 7;
    //        [u deleteCharactersInRange:r];
    //        [u insertString:@"_bigger" atIndex:loc];
    //        return u;
    //    }
    //
    //    return url;
}

- (NSString*) decodeHeart:(NSString*)aString {
    NSMutableString *s = [[aString mutableCopy] autorelease];
    [s replaceOccurrencesOfString:@"<3" withString:@"♥" options:0 range:NSMakeRange(0, [s length])];
    return s;
}

- (NSString*) stringValueFromNSXMLNode:(NSXMLNode*)node byXPath:(NSString*)xpath {
    NSArray *nodes = [node nodesForXPath:xpath error:NULL];
    if ([nodes count] != 1) {
        return nil;
    }
    return [(NSXMLNode *)[nodes objectAtIndex:0] stringValue];
}

- (id) initWithCallback:(id<TwitterTimelineCallback>)callback parent:(id)parent {
    _callback = callback;
    _parent = parent;
    return self;
}

- (NSString*) appendCode:(int)code to:(NSString*)string {
    return [string stringByAppendingFormat:@" (%d)", code];
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
    [_callback twitterStopTask];

    NSString *responseStr = [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding];
    
//    NSLog(@"responseArrived:%@", responseStr);
    
    NSXMLDocument *document = nil;
    
    if (responseStr) {
        document = [[[NSXMLDocument alloc] initWithXMLString:responseStr options:0 error:NULL] autorelease];
    }

//#define DEBUG 1
#ifdef DEBUG
    switch ((int) ((float) rand() / RAND_MAX * 10)) {
        case 0:
        case 1:
        case 2:
            code = 200;
            break;
        case 3:
            code = 400;
            break;
        case 4:
            code = 401;
            break;
        case 5:
            code = 500;
            break;
        case 6:
            code = 501;
            break;
        case 7:
            code = 502;
            break;
        case 8:
            code = 503;
            break;
        default:
            code = 404;
            break;
    }
#endif
    
    if (!document || code >= 400) {
        NSLog(@"status code: %d - response:%@", code, responseStr);        
        switch (code) {
            case 400:
                [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_HIT_API_LIMIT
                                                           originalMessage:[self appendCode:code 
                                                                                         to:NSLocalizedString(@"Exceeded the API rate limit", nil)]]];
                break;
            case 401:
                [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_NOT_AUTHORIZED
                                                           originalMessage:[self appendCode:code
                                                                                         to:NSLocalizedString(@"Not Authorized", nil)]]];
                break;
            case 500:
            case 502:
            case 503:
                [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_SERVER_ERROR
                                                           originalMessage:[self appendCode:code
                                                                                         to:NSLocalizedString(@"Twitter Server Error", nil)]]];
                break;
            default:
                [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER 
                                                           originalMessage:[self appendCode:code
                                                                                         to:NSLocalizedString(@"Unknown Error", nil)]]];
                break;
        }
        return;
    }
    
    NSArray *statuses = [document nodesForXPath:@"/statuses/status" error:NULL];
    if ([statuses count] == 0) {
        NSLog(@"status code: %d - response:%@", code, responseStr);
        [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER 
                                                   originalMessage:[self appendCode:code
                                                                                 to:NSLocalizedString(@"No message received", nil)]]];
    }
    
    for (NSXMLNode *status in statuses) {
        NTLNMessage *backStatus = [[[NTLNMessage alloc] init] autorelease];
        
        [backStatus setStatusId:[self stringValueFromNSXMLNode:status byXPath:@"id/text()"]];
        [backStatus setName:[[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"user/name/text()"]]];
        [backStatus setScreenName:[[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"user/screen_name/text()"]]];
        [backStatus setText:[[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"text/text()"]]];
        [backStatus setText:[self decodeHeart:[backStatus text]]];
        
        NSString *timestampStr = [[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"created_at/text()"]];
        [backStatus setTimestamp:[NSDate dateWithNaturalLanguageString:timestampStr]];
        
        NSString *iconUrl = [self convertToLargeIconUrl:[self stringValueFromNSXMLNode:status byXPath:@"user/profile_image_url/text()"]];
       
        [backStatus finishedToSetProperties];
        [_callback twitterStartTask];
        [_parent pushIconWaiter:backStatus forUrl:iconUrl];
        
        // keep last status id for "since" parameter
        [_parent setFriendsTimelineTimestamp:[backStatus timestamp]];
    }
}

- (void) connectionFailed:(NSError*)error {
    [_callback twitterStopTask];
    [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                               originalMessage:[error localizedDescription]]];
}

@end

@implementation TwitterPostCallbackHandler

- (id) initWithPostCallback:(id<TwitterPostCallback>)callback {
    _callback = callback;
    return self;
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
//    NSLog(@"post responseArrived:%@", [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding]);
    [_callback twitterStopTask];
    [_callback finishedToPost];
    [self autorelease];
}

- (void) connectionFailed:(NSError*)error {
    [_callback twitterStopTask];
    [_callback failedToPost:[error localizedDescription]];
    [self autorelease];
}

@end

@implementation TwitterFavoriteCallbackHandler

- (id) initWithStatusId:(NSString*)statusId callback:(id<TwitterFavoriteCallback>)callback {
    _callback = callback; // weak reference
    _statusId = statusId;
    [_statusId retain];
    return self;
}

- (void) dealloc {
    [_statusId release];
    [super dealloc];
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
    [_callback twitterStopTask];
    
    if (code == 200) {
        [_callback finishedToChangeFavorite:_statusId];
    } else {
        NSLog(@"favorite failed:%@", [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding]);
        [_callback failedToChangeFavorite:_statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                                                         originalMessage:NSLocalizedString(@"Creating favorite failure. unable to get connection.", nil)]];
    }

    [self autorelease];

}

- (void) connectionFailed:(NSError*)error {
    [_callback twitterStopTask];
    [_callback failedToChangeFavorite:_statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                                                      originalMessage:[error localizedDescription]]];
    [self autorelease];
}

@end


@implementation Twitter
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {

}

- (void) repliesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {
    
}

- (void) sentMessagesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {
    
}

- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password {
    
}

- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password {
    
}

- (void) destroyFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password {
    
}

@end

@implementation TwitterImpl

////////////////////////////////////////////////////////////////////

- (id) initWithCallback:(id<TwitterTimelineCallback, TwitterFavoriteCallback, TwitterPostCallback>)callback {
    [super init];
    _callback = callback;
    _waitingIconTwitterStatuses = [[NSMutableDictionary alloc] initWithCapacity:100];
    _iconRepository = [[NTLNIconRepository alloc] initWithIconCallback:self];
    return self;
}

- (void) dealloc {
    [_connectionForFriendTimeline release];
    [_connectionForReplies release];
    [_connectionForSentMessages release];
    [_connectionForFavorite release];
    [_connectionForPost release];
    [_waitingIconTwitterStatuses release];
    [_iconRepository release];
    [super dealloc];
}

#pragma mark methods for TwitterTimelineCallbackHandler
- (void) pushIconWaiter:(NTLNMessage*)waiter forUrl:(NSString*)url {
    NSMutableSet *set = [_waitingIconTwitterStatuses objectForKey:url];
    if (!set) {
        set = [[[NSMutableSet alloc] initWithCapacity:3] autorelease];
        [_waitingIconTwitterStatuses setObject:set forKey:url];
    }
    [set addObject:waiter];
    [_iconRepository registerUrl:url];
}

- (NSSet*) popIconWaiterSet:(NSString*)url {
    NSSet *back = [_waitingIconTwitterStatuses objectForKey:url];
    [back retain];
    [_waitingIconTwitterStatuses removeObjectForKey:url];
    [back autorelease];
    return back;
}

- (void) setFriendsTimelineTimestamp:(NSDate*)timestamp {
//    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [timestamp description]);
    [_friendsTimelineTimestamp release];
    _friendsTimelineTimestamp = timestamp;
    [_friendsTimelineTimestamp retain];
}

#pragma mark public methods
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {
    
    if (_connectionForFriendTimeline && ![_connectionForFriendTimeline isFinished]) {
        NSLog(@"connection for friend timeline is running.");
        return;
    }
    
    TwitterTimelineCallbackHandler *handler = [[TwitterTimelineCallbackHandler alloc] initWithCallback:_callback parent:self];
    
    NSString *url = [API_BASE stringByAppendingString:@"/statuses/friends_timeline.xml?count=200"];
    if (_friendsTimelineTimestamp) {
//        [[url stringByAppendingString:@"?since_id="] stringByAppendingString:_lastStatusIdForFriendTimeline];
        
        // @"%a,%d %b %Y %H:%M:%S GMT"
        NSCalendarDate *c = [_friendsTimelineTimestamp dateWithCalendarFormat:@"%a%%2C+%d+%b+%Y+%H%%3A%M%%3A%S+GMT" timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        url = [[url stringByAppendingString:@"&since="] stringByAppendingString:[c description]];
    }
    
//    NSLog(@"requesting: %@", url);
    
    [_connectionForFriendTimeline release];
    _connectionForFriendTimeline = [[NTLNAsyncUrlConnection alloc] initWithUrl:url
                                                                  username:username
                                                                  password:password
                                                                   usePost:post
                                                                  callback:handler];
    if (!_connectionForFriendTimeline) {
        NSLog(@"failed to get connection.");
        return;
    }

    [_callback twitterStartTask];
}

- (void) repliesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {

    if (_connectionForReplies && ![_connectionForReplies isFinished]) {
        NSLog(@"connection for replies is running.");
        return;
    }
    
    TwitterTimelineCallbackHandler *handler = [[TwitterTimelineCallbackHandler alloc] initWithCallback:_callback parent:self];
    
    [_connectionForReplies release];
    _connectionForReplies = [[NTLNAsyncUrlConnection alloc] initWithUrl:[API_BASE stringByAppendingString:@"/statuses/replies.xml"]
                                                                      username:username
                                                                      password:password
                                                                       usePost:post
                                                                      callback:handler];
    if (!_connectionForReplies) {
        NSLog(@"failed to get connection.");
        return;
    }
    
    [_callback twitterStartTask];
}

- (void) sentMessagesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {
    
    if (_connectionForSentMessages && ![_connectionForSentMessages isFinished]) {
        NSLog(@"connection for sent messages is running.");
        return;
    }
    
    TwitterTimelineCallbackHandler *handler = [[TwitterTimelineCallbackHandler alloc] initWithCallback:_callback parent:self];
    
    [_connectionForSentMessages release];
    _connectionForSentMessages = [[NTLNAsyncUrlConnection alloc] initWithUrl:[API_BASE stringByAppendingString:@"/statuses/user_timeline.xml"]
                                                               username:username
                                                               password:password
                                                                usePost:post
                                                               callback:handler];
    if (!_connectionForSentMessages) {
        NSLog(@"failed to get connection.");
        return;
    }
    
    [_callback twitterStartTask];
}

- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password {

    if (_connectionForPost && ![_connectionForPost isFinished]) {
        NSLog(@"connection for post is running.");
        return;
    }
    
    NSString *requestStr =  [@"status=" stringByAppendingString:[[NTLNXMLHTTPEncoder encoder] encodeHTTP:message]];
    requestStr = [requestStr stringByAppendingString:@"&source=natsulion"];
    
    TwitterPostCallbackHandler *handler = [[TwitterPostCallbackHandler alloc] initWithPostCallback:_callback];
    [_connectionForPost release];
    _connectionForPost = [[NTLNAsyncUrlConnection alloc] initPostConnectionWithUrl:[API_BASE stringByAppendingString:@"/statuses/update.xml"]
                                                                        bodyString:requestStr 
                                                                          username:username
                                                                          password:password
                                                                          callback:handler];
    
    //    NSLog(@"sent data [%@]", requestStr);
    
    if (!_connectionForPost) {
        [_callback failedToPost:@"Posting a message failure. unable to get connection."];
        return;
    }
    
    [_callback twitterStartTask];
}

- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password {
    
    if (_connectionForFavorite && ![_connectionForFavorite isFinished]) {
        NSLog(@"connection for favorite is running.");
        return;
    }
    
    NSMutableString *urlStr = [[[NSMutableString alloc] init] autorelease];
    [urlStr appendString:[API_BASE stringByAppendingString:@"/favorites/create/"]];
    [urlStr appendString:statusId];
    [urlStr appendString:@".xml"];
    
    TwitterFavoriteCallbackHandler *handler = [[TwitterFavoriteCallbackHandler alloc] initWithStatusId:statusId callback:_callback];
    [_connectionForFavorite release];
    _connectionForFavorite = [[NTLNAsyncUrlConnection alloc] initWithUrl:urlStr
                                                                username:username
                                                                password:password
                                                                 usePost:TRUE
                                                                callback:handler];
    
    //    NSLog(@"sent data [%@]", urlStr);
    
    if (!_connectionForFavorite) {
        [_callback failedToChangeFavorite:statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                                                         originalMessage:NSLocalizedString(@"Creating favorite failure. unable to get connection.", nil)]];
        return;
    }
    
    [_callback twitterStartTask];
}

- (void) destroyFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password {
    
    if (_connectionForFavorite && ![_connectionForFavorite isFinished]) {
        NSLog(@"connection for favorite is running.");
        return;
    }
    
    NSMutableString *urlStr = [[[NSMutableString alloc] init] autorelease];
    [urlStr appendString:[API_BASE stringByAppendingString:@"/favorites/destroy/"]];
    [urlStr appendString:statusId];
    [urlStr appendString:@".xml"];
    
    TwitterFavoriteCallbackHandler *handler = [[TwitterFavoriteCallbackHandler alloc] initWithStatusId:statusId callback:_callback];
    [_connectionForFavorite release];
    _connectionForFavorite = [[NTLNAsyncUrlConnection alloc] initWithUrl:urlStr
                                                                username:username
                                                                password:password
                                                                 usePost:TRUE
                                                                callback:handler];
    
    //    NSLog(@"sent data [%@]", urlStr);
    
    if (!_connectionForFavorite) {
        [_callback failedToChangeFavorite:statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                                                         originalMessage:NSLocalizedString(@"Destroying favorite failure. unable to get connection.", nil)]];
        return;
    }
    
    [_callback twitterStartTask];
}

#pragma mark icon callback
- (NSArray*) arrayWithSet:(NSSet*)set {
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    
    NSEnumerator *e = [set objectEnumerator];
    id i = [e nextObject];
    while (i) {
        [array addObject:i];
        i = [e nextObject];
    }
    
    return array;
}

- (void) finishedToGetIcon:(NSImage*)icon forKey:(NSString*)key {
    NSMutableArray *back = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
    NSSet* set = [self popIconWaiterSet:key];
    NSEnumerator *e = [set objectEnumerator];
    NTLNMessage *s = [e nextObject];
    while (s) {
        [_callback twitterStopTask];
        [icon setSize:NSMakeSize(48.0, 48.0)];
        [s setIcon:icon];
        [back addObject:s];
        s = [e nextObject];
    }
    [_callback finishedToGetTimeline:back];
}

- (void) failedToGetIconForKey:(NSString*)key {
    NSMutableArray *back = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
    [back addObjectsFromArray:[self arrayWithSet:[self popIconWaiterSet:key]]];
    [_callback finishedToGetTimeline:back];
    for (int i = 0; i < [[self popIconWaiterSet:key] count]; i++) {
        [_callback twitterStopTask];
    }
}

@end

///////////////////////////////////////////


@implementation TwitterCheck

- (void) checkAuthentication:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterCheckCallback>*)callback {

    _callback = callback;
    [_callback retain];
    
    _connection = [[NTLNAsyncUrlConnection alloc] initWithUrl:[API_BASE stringByAppendingString:@"/account/verify_credentials.xml"]
                                                 username:username
                                                 password:password
                                                  usePost:FALSE
                                                 callback:self];
    if (!_connection) {
        NSLog(@"failed to get connection.");
        [_callback finishedToCheck:NTLN_TWITTERCHECK_FAILURE];
    }
}

- (void) dealloc {
    [_callback release];
    [_connection release];
    [super dealloc];
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
    switch (code) {
        case 200:
            [_callback finishedToCheck:NTLN_TWITTERCHECK_SUCESS];
            break;
            
        case 401:
            [_callback finishedToCheck:NTLN_TWITTERCHECK_AUTH_FAILURE];
            break;
            
        default:
            [_callback finishedToCheck:NTLN_TWITTERCHECK_FAILURE];
            NSLog(@"%s: code=%d", __PRETTY_FUNCTION__, code);
            break;
    }
}

- (void) connectionFailed: (NSError*)error {
    [_callback finishedToCheck:NTLN_TWITTERCHECK_FAILURE];
}

@end
