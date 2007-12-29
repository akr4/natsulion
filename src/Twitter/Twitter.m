#import "Twitter.h"
#import "TwitterStatus.h"

@implementation TwitterPostCallbackHandler

- (id) initWithParentId:(id)parent {
    _parent = parent;
    return self;
}

- (void) responseArrived:(NSData*)response {
    [(Twitter*)_parent finishedToSendMessage];
    NSString *responseStr = [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding];
    NSLog(@"post responseArrived:%@", responseStr);
}

- (void) connectionFailed {
    NSLog(@"post failed");
}

@end


@implementation Twitter

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
    if (_friendTimelineCallback) {
        [_friendTimelineCallback release];
    }
    [_waitingIconTwitterStatuses release];
    [_iconRepository release];
    [super dealloc];
}

////////////////////////////////////////////////////////////////////
- (void) friendTimelineWithCallback:(NSObject<TimelineCallback>*)callback {
    
    if (_friendTimelineCallback) {
        NSLog(@"friendTimelineWithCallback: called while running");
    }
    [_friendTimelineCallback release];
    _friendTimelineCallback = callback;
    [_friendTimelineCallback retain];
    
    AsyncUrlConnection *connection = [[AsyncUrlConnection alloc] initWithUrl:@"http://twitter.com/statuses/friends_timeline.xml" andCallback:self];
    if (!connection) {
        NSLog(@"failed to get connection.");
        return;
    }

    [self startDownloading];

    NSLog(@"sending friend timeline request.");
    
}

- (void) responseArrived:(NSData*)response {

    [self stopDownloading];

    NSString *responseStr = [NSString stringWithCString:[response bytes] encoding:NSUTF8StringEncoding];
    
//    NSLog(@"responseArrived:%@", responseStr);
    
    NSXMLDocument *document;
    
    document = [[[NSXMLDocument alloc] initWithXMLString:responseStr options:0 error:NULL] autorelease];
    if (!document) {
        NSLog(@"parse error");
        NSLog(@"responseArrived:%@", responseStr);
    }
    
    NSArray *statuses = [document nodesForXPath:@"/statuses/status" error:NULL];
    for (NSXMLNode *status in statuses) {
        TwitterStatus *backStatus = [[[TwitterStatus alloc] init] autorelease];
        
        [backStatus setStatusId:[self stringValueFromNSXMLNode:status byXPath:@"id/text()"]];
        [backStatus setName:[self stringValueFromNSXMLNode:status byXPath:@"user/name/text()"]];
        [backStatus setScreenName:[self stringValueFromNSXMLNode:status byXPath:@"user/screen_name/text()"]];
        [backStatus setText:[self stringValueFromNSXMLNode:status byXPath:@"text/text()"]];
        [backStatus setTimestamp:[NSDate dateWithNaturalLanguageString:[self stringValueFromNSXMLNode:status byXPath:@"created_at/text()"]]];

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

- (void) connectionFailed {
    
}

- (void) sendMessage:(NSString*)message withCallback:(NSObject<TwitterPostCallback>*)callback {
    
    if (_twitterPostCallback) {
        NSLog(@"sendMessageWithCallback: called while running");
    }
    [_twitterPostCallback release];
    _twitterPostCallback = callback;
    [_twitterPostCallback retain];
    
    TwitterPostCallbackHandler *handler = [[[TwitterPostCallbackHandler alloc] initWithParentId:self] autorelease];
    NSString *requestStr =  [@"status=" stringByAppendingString:message];
    requestStr = [requestStr stringByAppendingString:@"&source=NatsuLion"];
    AsyncUrlConnection *connection = [[[AsyncUrlConnection alloc]
                                       initPostConnectionWithUrl:@"http://twitter.com/statuses/update.xml"
                                       andBodyString:requestStr andCallback:handler] autorelease];
    if (!connection) {
        NSLog(@"failed to get connection.");
        return;
    }

    [self startPosting];
    NSLog(@"sending post status request.");
}

- (void) finishedToSendMessage {
    [self stopPosting];
    [_twitterPostCallback finishedToPost];
}

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
