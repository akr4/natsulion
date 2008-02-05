#import "Twitter.h"

#import "NTLNXMLHTTPEncoder.h"

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

- (NSString*) stringValueFromNSXMLNode:(NSXMLNode*)node byXPath:(NSString*)xpath {
    NSArray *nodes = [node nodesForXPath:xpath error:NULL];
    if ([nodes count] != 1) {
        return nil;
    }
    return [(NSXMLNode *)[nodes objectAtIndex:0] stringValue];
}

- (id) initWithCallback:(id<TimelineCallback>)callback queue:(id<TwitterIconWaiterQueue>)iconWaiterQueue {
    _callback = callback;
    _iconWaiterQueue = iconWaiterQueue;
    _iconRepository = [[NTLNIconRepository alloc] initWithCallback:self];
    return self;
}

- (void) dealloc {
    [_iconRepository release];
    [super dealloc];
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
    
    NSString *responseStr = [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding];
    
//    NSLog(@"responseArrived:%@", responseStr);
    
    NSXMLDocument *document = nil;
    
    if (responseStr) {
        document = [[[NSXMLDocument alloc] initWithXMLString:responseStr options:0 error:NULL] autorelease];
    }
    
    if (!document || code >= 400) {
        NSLog(@"status code: %d - response:%@", code, responseStr);        
        switch (code) {
            case 400:
                [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_HIT_API_LIMIT originalMessage:nil]];
                break;
            case 401:
                [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_NOT_AUTHORIZED originalMessage:nil]];
                break;
            case 500:
            case 502:
            case 503:
                [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_SERVER_ERROR originalMessage:nil]];
                break;
            default:
                [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER originalMessage:nil]];
                break;
        }
        return;
    }
    
    NSArray *statuses = [document nodesForXPath:@"/statuses/status" error:NULL];
    if ([statuses count] == 0) {
        NSLog(@"status code: %d - response:%@", code, responseStr);
        [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER originalMessage:@"no message received"]];
    }
    
    for (NSXMLNode *status in statuses) {
        TwitterStatus *backStatus = [[[TwitterStatus alloc] init] autorelease];
        
        [backStatus setStatusId:[self stringValueFromNSXMLNode:status byXPath:@"id/text()"]];
        [backStatus setName:[[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"user/name/text()"]]];
        [backStatus setScreenName:[[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"user/screen_name/text()"]]];
        [backStatus setText:[[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"text/text()"]]];
        
        NSString *timestampStr = [[NTLNXMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"created_at/text()"]];
        [backStatus setTimestamp:[NSDate dateWithNaturalLanguageString:timestampStr]];
        
        NSString *iconUrl = [self convertToLargeIconUrl:[self stringValueFromNSXMLNode:status byXPath:@"user/profile_image_url/text()"]];
       
        [backStatus finishedToSetProperties];
        [_iconWaiterQueue pushIconWaiter:backStatus forUrl:iconUrl];
        [_iconRepository registerUrl:iconUrl];
    }
}

- (void) connectionFailed:(NSError*)error {
    [_callback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER originalMessage:[error localizedDescription]]];
}

- (void) finishedToGetIcon:(NSImage*)icon forKey:(NSString*)key {
    NSMutableArray *back = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
    NSSet* set = [_iconWaiterQueue popIconWaiterSet:key];
    NSEnumerator *e = [set objectEnumerator];
    TwitterStatus *s = [e nextObject];
    while (s) {
        [icon setSize:NSMakeSize(48.0, 48.0)];
        [s setIcon:icon];
        [back addObject:s];
        s = [e nextObject];        
    }
    [_callback finishedToGetTimeline:back];
}

- (void) failedToGetIconForKey:(NSString*)key {
    NSMutableArray *back = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
    [back addObjectsFromArray:[self arrayWithSet:[_iconWaiterQueue popIconWaiterSet:key]]];
    [_callback finishedToGetTimeline:back];
}

@end

@implementation TwitterPostCallbackHandler

- (id) initWithCallback:(id<TwitterPostCallback>)callback {
    _callback = callback;
    return self;
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
//    NSLog(@"post responseArrived:%@", [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding]);
    [_callback finishedToPost];
    [self autorelease];
}

- (void) connectionFailed:(NSError*)error {
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
    [_callback finishedToChangeFavorite:_statusId];
    NSLog(@"favorite responseArrived:%@", [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding]);
    [self autorelease];
}

- (void) connectionFailed:(NSError*)error {
    [_callback failedToChangeFavorite:_statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER originalMessage:[error localizedDescription]]];
    [self autorelease];
}

@end


@implementation Twitter
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post callback:(NSObject<TimelineCallback>*)callback {

}

- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterPostCallback>*)callback {
    
}

- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterFavoriteCallback>*)callback {
    
}

@end

@implementation TwitterImpl

// download status ////////////////////////////////////////////////////////////////

- (void) updateDownloadStatus {
    NSLog(@"*** %d - %d", _downloadingTimeline, [_waitingIconTwitterStatuses count]);
    if (!_downloadingTimeline && [_waitingIconTwitterStatuses count] == 0) {
        NSLog(@"aaaaa");
        [_timelineCallback finishedAll];
    }
}

- (void) startDownloading {
    _downloadingTimeline = TRUE;
    [self updateDownloadStatus];
}

- (void) stopDownloading {
    _downloadingTimeline = FALSE;
    [self updateDownloadStatus];
}

// TwitterIconWaiterQueue /////////////////////////////////////////////////////////////////
- (void) pushIconWaiter:(TwitterStatus*)waiter forUrl:(NSString*)url {
    NSMutableSet *set = [_waitingIconTwitterStatuses objectForKey:url];
    if (!set) {
        set = [[[NSMutableSet alloc] initWithCapacity:3] autorelease];
        [_waitingIconTwitterStatuses setObject:set forKey:url];
    }
    [set addObject:waiter];
    [self stopDownloading];
}

- (NSSet*) popIconWaiterSet:(NSString*)url {
    NSSet *back = [_waitingIconTwitterStatuses objectForKey:url];
    [back retain];
    [_waitingIconTwitterStatuses removeObjectForKey:url];
    [back autorelease];
    [self updateDownloadStatus];
    return back;
}

////////////////////////////////////////////////////////////////////
- (id) init {
    [super init];
    _waitingIconTwitterStatuses = [[NSMutableDictionary alloc] initWithCapacity:100];
    
    return self;
}

- (void) dealloc {
    [_connectionForFriendTimeline release];
    [_connectionForPost release];
    [_waitingIconTwitterStatuses release];
    [super dealloc];
}

////////////////////////////////////////////////////////////////////
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password usePost:(BOOL)post callback:(NSObject<TimelineCallback>*)callback {
    
    if (_connectionForFriendTimeline && ![_connectionForFriendTimeline isFinished]) {
        NSLog(@"connection for friend timeline is running.");
        return;
    }
    
    _timelineCallback = callback;
    
    TwitterTimelineCallbackHandler *handler = [[TwitterTimelineCallbackHandler alloc] initWithCallback:callback queue:self];
    
    [_connectionForFriendTimeline release];
    _connectionForFriendTimeline = [[NTLNAsyncUrlConnection alloc] initWithUrl:@"http://twitter.com/statuses/friends_timeline.xml" 
                                                                  username:username
                                                                  password:password
                                                                   usePost:post
                                                                  callback:handler];
    if (!_connectionForFriendTimeline) {
        NSLog(@"failed to get connection.");
        return;
    }

    [self startDownloading];
}

// sendMessage //////////////////////////////////////////////////////////////////////////////////

- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterPostCallback>*)callback {
    
    if (_connectionForPost && ![_connectionForPost isFinished]) {
        NSLog(@"connection for post is running.");
        return;
    }

    NSString *requestStr =  [@"status=" stringByAppendingString:[[NTLNXMLHTTPEncoder encoder] encodeHTTP:message]];
    requestStr = [requestStr stringByAppendingString:@"&source=natsulion"];

    TwitterPostCallbackHandler *handler = [[TwitterPostCallbackHandler alloc] initWithCallback:callback];
    [_connectionForPost release];
    _connectionForPost = [[NTLNAsyncUrlConnection alloc] initPostConnectionWithUrl:@"http://twitter.com/statuses/update.xml"
                                                                    bodyString:requestStr 
                                                                      username:username
                                                                      password:password
                                                                      callback:handler];
    
//    NSLog(@"sent data [%@]", requestStr);
    
    if (!_connectionForPost) {
        [callback failedToPost:@"Posting a message failure. unable to get connection."];
        return;
    }
}

// createFavorite /////////////////////////////////////////////////////////////////////////////////////////

- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterFavoriteCallback>*)callback {

    if (_connectionForFavorite && ![_connectionForFavorite isFinished]) {
        NSLog(@"connection for favorite is running.");
        return;
    }
    
    NSMutableString *urlStr = [[[NSMutableString alloc] init] autorelease];
    [urlStr appendString:@"http://twitter.com/favourings/create/"];
    [urlStr appendString:statusId];
    [urlStr appendString:@".xml"];
    
    TwitterFavoriteCallbackHandler *handler = [[TwitterFavoriteCallbackHandler alloc] initWithStatusId:statusId callback:callback];
    [_connectionForPost release];
    _connectionForFavorite = [[NTLNAsyncUrlConnection alloc] initWithUrl:urlStr
                                                            username:username
                                                            password:password
                                                             usePost:FALSE
                                                            callback:handler];
    
    NSLog(@"sent data [%@]", urlStr);
    
    if (!_connectionForFavorite) {
        [callback failedToChangeFavorite:statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                                                        originalMessage:@"Sending a message failure. unable to get connection."]];
        return;
    }
}

@end

///////////////////////////////////////////


@implementation TwitterCheck

- (void) checkAuthentication:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterCheckCallback>*)callback {

    _callback = callback;
    [_callback retain];
    
    _connection = [[NTLNAsyncUrlConnection alloc] initWithUrl:@"http://twitter.com/account/verify_credentials.xml" 
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
