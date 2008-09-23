#import "Twitter.h"
#import "NTLNConfiguration.h"
#import "NTLNXMLHTTPEncoder.h"

#define API_BASE @"http://twitter.com"

//#define DEBUG

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

- (NSString*) description
{
    return _originalMessage;
}
@end

#pragma mark -
#pragma mark Timeline Callback Handlers

// provides common function to its subclasses
@interface NTLNAbstractTwitterCallbackHandler : NSObject<NTLNAsyncUrlConnectionCallback> 
{
    
}
- (NSString*) stringValueFromNSXMLNode:(NSXMLNode*)node byXPath:(NSString*)xpath;

@end

@implementation NTLNAbstractTwitterCallbackHandler

- (NSString*) stringValueFromNSXMLNode:(NSXMLNode*)node byXPath:(NSString*)xpath
{
    NSArray *nodes = [node nodesForXPath:xpath error:NULL];
    if ([nodes count] != 1) {
        return nil;
    }
    return [(NSXMLNode *)[nodes objectAtIndex:0] stringValue];
}

- (void) responseArrived:(NSData*)response statusCode:(int)code
{
    [self autorelease];
}

- (void) connectionFailed:(NSError*)error
{
    [self autorelease];
}

@end

// provides common function and template methods to 'retrieving timeline' handlers
@interface NTLNAbstractTimelineCallbackHandler : NTLNAbstractTwitterCallbackHandler 
{
@protected
    id<TwitterTimelineCallback> _callback;
    id _parent;
}
- (id) initWithCallback:(id<TwitterTimelineCallback>)callback parent:(id)parent;
- (void) parseResponse:(NSXMLDocument*)document;
@end

@implementation NTLNAbstractTimelineCallbackHandler
- (NSString*) convertToLargeIconUrl:(NSString*)url {
    return url;
}

- (NSString*) decodeHeart:(NSString*)aString {
    NSMutableString *s = [[aString mutableCopy] autorelease];
    [s replaceOccurrencesOfString:@"<3" withString:@"♥" options:0 range:NSMakeRange(0, [s length])];
    return s;
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
    [self autorelease];
    [_callback twitterStopTask];
    
    NSMutableData *cstringStyleData = [[response mutableCopy] autorelease];
    [cstringStyleData appendData:[NSData dataWithBytes:"\0" length:1]];
    NSString *responseStr = [NSString stringWithCString:[cstringStyleData bytes] encoding:NSUTF8StringEncoding];
    
    //    NSLog(@"responseArrived:%@", responseStr);
    
    NSXMLDocument *document = nil;
    
    if (responseStr) {
        document = [[[NSXMLDocument alloc] initWithXMLString:responseStr options:0 error:NULL] autorelease];
    }
    
//#define DEBUG_RANDOM_ERROR 1
#ifdef DEBUG_RANDOM_ERROR
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
    
    if (code != 200 && (!document || code >= 400)) {
        NSLog(@"status code: %d - response:%@", code, responseStr);        
        switch (code) {
            case 400:
                [_parent apiRateLimitExceeded];
                [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_HIT_API_LIMIT
                                                           originalMessage:[self appendCode:code to:NSLocalizedString(@"Exceeded API rate limit", nil)]]];
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
    
    if (document) {
        [_parent apiRateLimitReset];
        [self parseResponse:document];
    }
}

- (void) parseResponse:(NSXMLDocument*)document
{
    // subclass must imeplement  
    // might call:
    // [_parent pushIconWaiter:backStatus forUrl:iconUrl] with [_callback twitterStartTask]
    // [_parent setFriendsTimelineTimestamp:lastTimestamp] (for friends_timeline only)
    // call any other parent methods
}

- (void) connectionFailed:(NSError*)error {
    [self autorelease];
    [_callback twitterStopTask];

    NSLog([error description]);

    [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                               originalMessage:[error localizedDescription]]];
}

@end

@interface TwitterTimelineCallbackHandler : NTLNAbstractTimelineCallbackHandler
{
}
@end

@implementation TwitterTimelineCallbackHandler

- (void) parseResponse:(NSXMLDocument*)document
{
    NSArray *statuses = [document nodesForXPath:@"/statuses/status" error:NULL];
    if ([statuses count] == 0) {
        //        NSLog(@"status code: %d - response:%@", code, responseStr);
        return;
    }
    
#ifdef DEBUG
    NSLog(@"status count = %d", [statuses count]);
#endif
    
    NSDate *lastTimestamp = nil;
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
        if ([[backStatus timestamp] compare:[NSDate date]] == NSOrderedDescending) {
            [_parent gotInvalidTimestamp];
        } else {
            [_parent gotValidTimestampAfterInvalidOne];
            if (!lastTimestamp) {
                lastTimestamp = [backStatus timestamp];
            } else {
                lastTimestamp = [lastTimestamp laterDate:[backStatus timestamp]];
            }
            [_parent setFriendsTimelineTimestamp:lastTimestamp];
        }
    }
}

@end

@interface TwitterDirectMessagesCallbackHandler : NTLNAbstractTimelineCallbackHandler
{
}
@end

@implementation TwitterDirectMessagesCallbackHandler

- (void) parseResponse:(NSXMLDocument*)document
{
    NSArray *statuses = [document nodesForXPath:@"/direct-messages/direct_message" error:NULL];
    if ([statuses count] == 0) {
        NSLog(@"DM not found");
        return;
    }
    
#ifdef DEBUG
    NSLog(@"DM count = %d", [statuses count]);
#endif
    
    for (NSXMLNode *status in statuses) {
        NTLNMessage *backStatus = [[[NTLNMessage alloc] init] autorelease];
        
        [backStatus setStatusId:[self stringValueFromNSXMLNode:status byXPath:@"id/text()"]];
        [backStatus setName:[[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"sender/name/text()"]]];
        [backStatus setScreenName:[[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"sender/screen_name/text()"]]];
        [backStatus setText:[[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"text/text()"]]];
        [backStatus setText:[self decodeHeart:[backStatus text]]];
        
        NSString *timestampStr = [[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"created_at/text()"]];
        [backStatus setTimestamp:[NSDate dateWithNaturalLanguageString:timestampStr]];
        
        NSString *iconUrl = [self convertToLargeIconUrl:[self stringValueFromNSXMLNode:status byXPath:@"sender/profile_image_url/text()"]];
        
        [backStatus setReplyType:NTLN_MESSAGE_REPLY_TYPE_DIRECT];
        
        //        NSLog(@"DM { %@ }", backStatus);
        [backStatus finishedToSetProperties];
        [_callback twitterStartTask];
        [_parent pushIconWaiter:backStatus forUrl:iconUrl];
    }
}

@end

@interface TwitterRateLimitStatusCallbackHandler : NTLNAbstractTwitterCallbackHandler
{
    id<TwitterRateLimitStatusCallback> _callback;
    id _parent;
}
@end

@implementation TwitterRateLimitStatusCallbackHandler

- (id) initWithCallback:(id<TwitterRateLimitStatusCallback>) callback parent:(id)parent
{
    _callback = callback;
    _parent = parent;
    return self;
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
    [self autorelease];
    [_callback twitterStopTask];
    
    NSMutableData *cstringStyleData = [[response mutableCopy] autorelease];
    [cstringStyleData appendData:[NSData dataWithBytes:"\0" length:1]];
    NSString *responseStr = [NSString stringWithCString:[cstringStyleData bytes] encoding:NSUTF8StringEncoding];
    
    NSXMLDocument *document = nil;
    
    if (responseStr) {
        document = [[[NSXMLDocument alloc] initWithXMLString:responseStr options:0 error:NULL] autorelease];
    }
    
    if (code != 200 || !document) {
        NSLog(@"status code: %d - response:%@", code, responseStr);        
    } else {
        NSArray *nodes = [document nodesForXPath:@"/hash" error:NULL];
        if ([nodes count] == 0) {
            return;
        }
        
        NSXMLNode *status = [nodes objectAtIndex:0];
        
        int remainingHits = [[self stringValueFromNSXMLNode:status byXPath:@"remaining-hits/text()"] intValue];
        int hourlyLimit = [[self stringValueFromNSXMLNode:status byXPath:@"hourly-limit/text()"] intValue];
        NSDate *resetTime = [NSCalendarDate dateWithString:[self stringValueFromNSXMLNode:status byXPath:@"reset-time/text()"]
                                            calendarFormat:@"%Y-%m-%dT%H:%M:%S+%z"];
        
        [_parent rateLimitStatusWithRemainingHits:remainingHits hourlyLimit:hourlyLimit resetTime:resetTime];
        [_callback rateLimitStatusWithRemainingHits:remainingHits hourlyLimit:hourlyLimit resetTime:resetTime];
    }
}

- (void) connectionFailed:(NSError*)error {
    [self autorelease];
    [_callback twitterStopTask];
    NSLog([error description]);
}

@end

@interface TwitterPostCallbackHandler : NTLNAbstractTwitterCallbackHandler {
    id<TwitterPostCallback> _callback;
}
- (id) initWithPostCallback:(id<TwitterPostCallback>)callback;
@end

@implementation TwitterPostCallbackHandler

- (id) initWithPostCallback:(id<TwitterPostCallback>)callback {
    _callback = callback;
    return self;
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
//    NSLog(@"post responseArrived:%@", [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding]);
    [self autorelease];
    [_callback twitterStopTask];
    [_callback finishedToPost];
}

- (void) connectionFailed:(NSError*)error {
    [self autorelease];
    [_callback twitterStopTask];
    [_callback failedToPost:[error localizedDescription]];
}

@end

@interface TwitterFavoriteCallbackHandler : NTLNAbstractTwitterCallbackHandler {
    id<TwitterFavoriteCallback> _callback;
    NSString *_statusId;
}
- (id) initWithStatusId:(NSString*)statusId callback:(id<TwitterFavoriteCallback>)callback;
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
    [self autorelease];
    [_callback twitterStopTask];
    
    if (code == 200) {
        [_callback finishedToChangeFavorite:_statusId];
    } else {
        NSLog(@"favorite failed:%@", [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding]);
        [_callback failedToChangeFavorite:_statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                                                         originalMessage:NSLocalizedString(@"Creating favorite failure. unable to get connection.", nil)]];
    }
}

- (void) connectionFailed:(NSError*)error {
    [self autorelease];
    [_callback twitterStopTask];
    [_callback failedToChangeFavorite:_statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                                                      originalMessage:[error localizedDescription]]];
}

@end

#pragma mark -
#pragma mark Twitter

@implementation Twitter
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {

}

- (void) repliesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {
    
}

- (void) sentMessagesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {
    
}

- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password {
    
}

- (void) directMessagesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {
    
}

- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password {
    
}

- (void) destroyFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password {
    
}

- (void) rateLimitStatusWithUsername:(NSString*)username password:(NSString*)password {
    
}

- (int) remainingHits
{
    return 0;
}

- (int) hourlyLimit
{
    return 0;
}

- (NSDate*) resetTime
{
    return nil;
}

@end

@implementation TwitterImpl

////////////////////////////////////////////////////////////////////

- (id) initWithCallback:(id<TwitterTimelineCallback, TwitterFavoriteCallback, TwitterPostCallback, TwitterRateLimitStatusCallback>)callback {
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
    [_connectionForDirectMessages release];
    [_connectionForRateLimitStatus release];
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
    if (!_friendsTimelineTimestamp || [timestamp compare:_friendsTimelineTimestamp] == NSOrderedDescending) {
        [_friendsTimelineTimestamp release];
        _friendsTimelineTimestamp = timestamp;
        [_friendsTimelineTimestamp retain];
    }
}

- (void) gotInvalidTimestamp
{
    NSLog(@"future timestamp returned from Twitter");
    _invalidTimestampReturned = true;
}

- (void) gotValidTimestampAfterInvalidOne
{
    if (_invalidTimestampReturned) {
        NSLog(@"valid timestamp returned.");
    }
    _invalidTimestampReturned = false;
}

- (void) apiRateLimitExceeded
{
    _apiLimitExceeded = true;
    if (_remainingHits > 0) {
        _remainingHits = 0;
    }
}

- (void) apiRateLimitReset
{
}

- (void) apiUsed
{
    if ([_resetTime compare:[NSDate date]] == NSOrderedAscending) {
        NSLog(@"resetTime is passed.");
        _remainingHits = _hourlyLimit;
        [_resetTime release];
        _resetTime = nil;
    }
    _remainingHits--;
}

- (void) rateLimitStatusWithRemainingHits:(int)remainingHits hourlyLimit:(int)hourlyLimit resetTime:(NSDate*)resetTime
{
    NSLog(@"limit: %d / %d, %@", remainingHits, hourlyLimit, resetTime);
    
    _remainingHits = remainingHits;
    _hourlyLimit = hourlyLimit;

    [_resetTime release];
    _resetTime = resetTime;
    [_resetTime retain];
}

#pragma mark public methods
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post {
    
    if (_connectionForFriendTimeline && ![_connectionForFriendTimeline isFinished]) {
        NSLog(@"connection for friend timeline is running.");
        return;
    }
    
    TwitterTimelineCallbackHandler *handler = [[TwitterTimelineCallbackHandler alloc] initWithCallback:_callback parent:self];

    // in the case of invalid (future) timestamp is returned from API, use older timestamp and less count value
    int count;
    if (_invalidTimestampReturned) {
        count = 20;
    } else {
        count = 100;
    }

    NSString *url = [API_BASE stringByAppendingString:[NSString stringWithFormat:@"/statuses/friends_timeline.xml?count=%d", count]];

    if (_friendsTimelineTimestamp) {
//        [[url stringByAppendingString:@"?since_id="] stringByAppendingString:_lastStatusIdForFriendTimeline];
        
        // accept 5 seconds clock lag in Twitter servers
        NSDate *since = [[[NSDate alloc] initWithTimeInterval:-5 sinceDate:_friendsTimelineTimestamp] autorelease];
        
        // @"%a,%d %b %Y %H:%M:%S GMT"
        NSCalendarDate *c = [since dateWithCalendarFormat:@"%a,+%d+%b+%Y+%H:%M:%S+GMT" timeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
        url = [[url stringByAppendingString:@"&since="] stringByAppendingString:[c description]];
    }
    
#ifdef DEBUG
    NSLog(@"requesting: %@", url);
#endif
    
    if (!post) {
        [self apiUsed];
    }
    
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
    
    NSString *url = [API_BASE stringByAppendingString:@"/statuses/replies.xml"];

#ifdef DEBUG
    NSLog(@"requesting: %@", url);
#endif
    
    if (!post) {
        [self apiUsed];
    }
    
    [_connectionForReplies release];
    _connectionForReplies = [[NTLNAsyncUrlConnection alloc] initWithUrl:url
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

    NSString *url = [API_BASE stringByAppendingString:@"/statuses/user_timeline.xml"];

#ifdef DEBUG
    NSLog(@"requesting: %@", url);
#endif
    
    if (!post) {
        [self apiUsed];
    }
    
    [_connectionForSentMessages release];
    _connectionForSentMessages = [[NTLNAsyncUrlConnection alloc] initWithUrl:url
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

- (void) directMessagesWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post
{
    if (_connectionForDirectMessages && ![_connectionForDirectMessages isFinished]) {
        NSLog(@"connection for direct messages is running.");
        return;
    }
    
    TwitterDirectMessagesCallbackHandler *handler = [[TwitterDirectMessagesCallbackHandler alloc] initWithCallback:_callback parent:self];

    NSString *url = [API_BASE stringByAppendingString:@"/direct_messages.xml"];

#ifdef DEBUG
    NSLog(@"requesting: %@", url);
#endif
    
    [self apiUsed];

    [_connectionForDirectMessages release];
    _connectionForDirectMessages = [[NTLNAsyncUrlConnection alloc] initWithUrl:url
                                                                    username:username
                                                                    password:password
                                                                     usePost:false // direct_messages does not accept POST
                                                                    callback:handler];
    if (!_connectionForDirectMessages) {
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
    
    NSString *url = [API_BASE stringByAppendingString:@"/statuses/update.xml"];
    
#ifdef DEBUG
    NSLog(@"requesting: %@", url);
#endif

    TwitterPostCallbackHandler *handler = [[TwitterPostCallbackHandler alloc] initWithPostCallback:_callback];
    [_connectionForPost release];
    _connectionForPost = [[NTLNAsyncUrlConnection alloc] initPostConnectionWithUrl:url
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
    
    NSMutableString *url = [[[NSMutableString alloc] init] autorelease];
    [url appendString:[API_BASE stringByAppendingString:@"/favorites/create/"]];
    [url appendString:statusId];
    [url appendString:@".xml"];
    
    TwitterFavoriteCallbackHandler *handler = [[TwitterFavoriteCallbackHandler alloc] initWithStatusId:statusId callback:_callback];

#ifdef DEBUG
    NSLog(@"requesting: %@", url);
#endif
    
    [_connectionForFavorite release];
    _connectionForFavorite = [[NTLNAsyncUrlConnection alloc] initWithUrl:url
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
    
    NSMutableString *url = [[[NSMutableString alloc] init] autorelease];
    [url appendString:[API_BASE stringByAppendingString:@"/favorites/destroy/"]];
    [url appendString:statusId];
    [url appendString:@".xml"];
    
    TwitterFavoriteCallbackHandler *handler = [[TwitterFavoriteCallbackHandler alloc] initWithStatusId:statusId callback:_callback];
    
#ifdef DEBUG
    NSLog(@"requesting: %@", url);
#endif
    
    [_connectionForFavorite release];
    _connectionForFavorite = [[NTLNAsyncUrlConnection alloc] initWithUrl:url
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

- (void) rateLimitStatusWithUsername:(NSString*)username password:(NSString*)password
{
    if (_connectionForRateLimitStatus && ![_connectionForRateLimitStatus isFinished]) {
        NSLog(@"connection for direct messages is running.");
        return;
    }
    
    TwitterRateLimitStatusCallbackHandler *handler = [[TwitterRateLimitStatusCallbackHandler alloc] initWithCallback:_callback parent:self];
    
    NSString *url = [API_BASE stringByAppendingString:@"/account/rate_limit_status.xml"];
    
#ifdef DEBUG
    NSLog(@"requesting: %@", url);
#endif
    
    [_connectionForRateLimitStatus release];
    _connectionForRateLimitStatus = [[NTLNAsyncUrlConnection alloc] initWithUrl:url
                                                                      username:username
                                                                      password:password
                                                                       usePost:false
                                                                      callback:handler];
    if (!_connectionForRateLimitStatus) {
        NSLog(@"failed to get connection.");
        return;
    }
    
    [_callback twitterStartTask];
}

- (int) remainingHits
{
    return _remainingHits;
}

- (int) hourlyLimit
{
    return _hourlyLimit;
}

- (NSDate*) resetTime
{
    return _resetTime;
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
    for (int i = 0; i < [[self popIconWaiterSet:key] count]; i++) {
        [_callback twitterStopTask];
    }
    [_callback finishedToGetTimeline:back];
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
