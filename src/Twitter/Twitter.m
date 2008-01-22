#import "Twitter.h"
#import "TwitterStatus.h"
#import "XMLHTTPEncoder.h"

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

@implementation TwitterPostCallbackHandler

- (id) initWithCallback:(id<TwitterPostInternalCallback>)callback {
    _callback = callback;
    return self;
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
    [_callback finishedToPost];
//    NSString *responseStr = [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding];
//    NSLog(@"post responseArrived:%@", responseStr);
}

- (void) connectionFailed:(NSError*)error {
    [_callback failedToPost:[error localizedDescription]];
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
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password callback:(NSObject<TimelineCallback>*)callback {

}

- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterPostCallback>*)callback {
    
}

- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterFavoriteCallback>*)callback {
    
}

@end

@implementation TwitterImpl

// internal 
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

- (void) updateDownloadStatus {
    if (_postingMessage || _downloadingTimeline || [_waitingIconTwitterStatuses count] > 0) {
        [_friendTimelineCallback started];
    }
    
    if (!_postingMessage && !_downloadingTimeline && [_waitingIconTwitterStatuses count] == 0) {
        [_friendTimelineCallback stopped];
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

- (void) startPosting {
    _postingMessage = TRUE;
    [self updateDownloadStatus];
}

- (void) stopPosting {
    _postingMessage = FALSE;
    [self updateDownloadStatus];
}


- (void) finishWaiting:(NSString*)key {
    [_waitingIconTwitterStatuses removeObjectForKey:key];
    [self updateDownloadStatus];
}


- (NSString*) stringValueFromNSXMLNode:(NSXMLNode*)node byXPath:(NSString*)xpath {
    NSArray *nodes = [node nodesForXPath:xpath error:NULL];
    if ([nodes count] != 1) {
        return nil;
    }
    return [(NSXMLNode *)[nodes objectAtIndex:0] stringValue];
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

////////////////////////////////////////////////////////////////////
- (id) init {
    [super init];
    _waitingIconTwitterStatuses = [[NSMutableDictionary alloc] initWithCapacity:100];
    _iconRepository = [[IconRepository alloc] initWithCallback:self];
    return self;
}

- (void) dealloc {
    [_connectionForFriendTimeline release];
    [_connectionForPost release];
    [_waitingIconTwitterStatuses release];
    [_iconRepository release];
    [super dealloc];
}

////////////////////////////////////////////////////////////////////
- (void) friendTimelineWithUsername:(NSString*)username password:(NSString*)password callback:(NSObject<TimelineCallback>*)callback {
    
    _friendTimelineCallback = callback;
    
    [_connectionForFriendTimeline release];
    _connectionForFriendTimeline = [[AsyncUrlConnection alloc] initWithUrl:@"http://twitter.com/statuses/friends_timeline.xml" 
                                                                  username:username
                                                                  password:password
                                                                  callback:self];
    if (!_connectionForFriendTimeline) {
        NSLog(@"failed to get connection.");
        return;
    }

    [self startDownloading];
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {

    [self stopDownloading];

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
                [_friendTimelineCallback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_HIT_API_LIMIT originalMessage:nil]];
                break;
            case 401:
                [_friendTimelineCallback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_NOT_AUTHORIZED originalMessage:nil]];
                break;
            case 500:
            case 502:
            case 503:
                [_friendTimelineCallback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_SERVER_ERROR originalMessage:nil]];
                break;
            default:
                [_friendTimelineCallback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER originalMessage:nil]];
                break;
        }
        return;
    }
    
    NSArray *statuses = [document nodesForXPath:@"/statuses/status" error:NULL];
    if ([statuses count] == 0) {
        NSLog(@"status code: %d - response:%@", code, responseStr);
        [_friendTimelineCallback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER originalMessage:@"no message received"]];
    }
    
    for (NSXMLNode *status in statuses) {
        TwitterStatus *backStatus = [[[TwitterStatus alloc] init] autorelease];
        
        [backStatus setStatusId:[self stringValueFromNSXMLNode:status byXPath:@"id/text()"]];
        [backStatus setName:[[XMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"user/name/text()"]]];
        [backStatus setScreenName:[[XMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"user/screen_name/text()"]]];
        [backStatus setText:[[XMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"text/text()"]]];
        
        NSString *timestampStr = [[XMLHTTPEncoder encoder] decodeXML:[self stringValueFromNSXMLNode:status byXPath:@"created_at/text()"]];
        [backStatus setTimestamp:[NSDate dateWithNaturalLanguageString:timestampStr]];

        NSString *iconUrl = [self convertToLargeIconUrl:[self stringValueFromNSXMLNode:status byXPath:@"user/profile_image_url/text()"]];
        NSMutableSet *set = [_waitingIconTwitterStatuses objectForKey:iconUrl];
        if (!set) {
            set = [[[NSMutableSet alloc] initWithCapacity:3] autorelease];
            [_waitingIconTwitterStatuses setObject:set forKey:iconUrl];
        }
        
        [backStatus finishedToSetProperties];
        
        [set addObject:backStatus];
        [_iconRepository registerUrl:iconUrl];
        
//        NSLog(@"%@, %@", [backStatus statusId], [backStatus name]);
    }

}

- (void) connectionFailed:(NSError*)error {
    [_friendTimelineCallback failedToGetTimeline:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER originalMessage:[error localizedDescription]]];
}

// sendMessage //////////////////////////////////////////////////////////////////////////////////

- (void) sendMessage:(NSString*)message username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterPostCallback>*)callback {
    
    if (_twitterPostCallback) {
        NSLog(@"%s: Warning: called while running (_twitterPostCallback)", __PRETTY_FUNCTION__);
    }
    _twitterPostCallback = callback;
    
    if (_postCallbackHandler) {
        NSLog(@"%s: Warning: called while running (_postCallbackHandler)", __PRETTY_FUNCTION__);
    }
    [_postCallbackHandler release];
    _postCallbackHandler = [[TwitterPostCallbackHandler alloc] initWithCallback:self];

    NSString *requestStr =  [@"status=" stringByAppendingString:[[XMLHTTPEncoder encoder] encodeHTTP:message]];
    requestStr = [requestStr stringByAppendingString:@"&source=natsulion"];

    [_connectionForPost release];
    _connectionForPost = [[AsyncUrlConnection alloc] initPostConnectionWithUrl:@"http://twitter.com/statuses/update.xml"
                                                                    bodyString:requestStr 
                                                                      username:username
                                                                      password:password
                                                                      callback:_postCallbackHandler];
    
//    NSLog(@"sent data [%@]", requestStr);
    
    if (!_connectionForPost) {
        [_twitterPostCallback failedToPost:@"Posting a message failure. unable to get connection."];
        _twitterPostCallback = nil;
        return;
    }

    [self startPosting];
//    NSLog(@"sending post status request.");
}

- (void) finishedToPost {
    [self stopPosting];
    [_twitterPostCallback finishedToPost];
    _twitterPostCallback = nil;
    [_postCallbackHandler release];
    _postCallbackHandler = nil;
}

- (void) failedToPost:(NSString*)message {
    [self stopPosting];
    [_twitterPostCallback failedToPost:message];
    _twitterPostCallback = nil;
    [_postCallbackHandler release];
    _postCallbackHandler = nil;
}

// createFavorite /////////////////////////////////////////////////////////////////////////////////////////

- (void) createFavorite:(NSString*)statusId username:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterFavoriteCallback>*)callback {
    _favoriteCallbackHandler = [[TwitterFavoriteCallbackHandler alloc] initWithStatusId:statusId callback:callback];
    
    NSMutableString *urlStr = [[[NSMutableString alloc] init] autorelease];
    [urlStr appendString:@"http://twitter.com/favourings/create/"];
    [urlStr appendString:statusId];
    [urlStr appendString:@".xml"];
    
    [_connectionForFavorite release];
    _connectionForFavorite = [[AsyncUrlConnection alloc] initWithUrl:urlStr
                                                            username:username
                                                            password:password
                                                            callback:_favoriteCallbackHandler];
    
    NSLog(@"sent data [%@]", urlStr);
    
    if (!_connectionForFavorite) {
        [callback failedToChangeFavorite:statusId errorInfo:[NTLNErrorInfo infoWithType:NTLN_ERROR_TYPE_OTHER
                                                                        originalMessage:@"Sending a message failure. unable to get connection."]];
        return;
    }
}

// /////////////////////////////////////////////////////////////////////////////
- (void) finishedToGetIcon:(NSImage*)icon forKey:(NSString*)key {
    NSMutableArray *back = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];

    NSSet* set = [_waitingIconTwitterStatuses objectForKey:key];
    NSEnumerator *e = [set objectEnumerator];
    TwitterStatus *s = [e nextObject];
    while (s) {
        NSSize size;
        size.width = 48;
        size.height = 48;
        [icon setSize:size];
        [s setIcon:icon];
        [back addObject:s];
        s = [e nextObject];        
    }
    
    [self finishWaiting:key];
    [_friendTimelineCallback finishedToGetTimeline:back];
}

- (void) failedToGetIconForKey:(NSString*)key {
    NSMutableArray *back = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
    [back addObjectsFromArray:[self arrayWithSet:[_waitingIconTwitterStatuses objectForKey:key]]];

    [self finishWaiting:key];
    [_friendTimelineCallback finishedToGetTimeline:back];
}


@end

///////////////////////////////////////////


@implementation TwitterCheck

- (void) checkAuthentication:(NSString*)username password:(NSString*)password callback:(NSObject<TwitterCheckCallback>*)callback {

    _callback = callback;
    [_callback retain];
    
    _connection = [[AsyncUrlConnection alloc] initWithUrl:@"http://twitter.com/account/verify_credentials.xml" 
                                                username:username
                                                password:password
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
