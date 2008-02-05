#import "NTLNIconRepository.h"


@implementation NTLNIconRepository

- (id) initWithCallback:(NSObject<NTLNIconCallback>*)callback {
    _callback = callback;
    [_callback retain];
    _cache = [[NSMutableDictionary alloc] initWithCapacity:100];
    _waitings = [[NSMutableSet alloc] initWithCapacity:100];
    return self;
}

- (void) dealloc {
    [_callback release];
    [_cache release];
    [_waitings release];
    [_currentUrl release];
    [_connection release];
    [super dealloc];
}

- (void) processNextUrl {
    if (_connection != nil) {
//        NSLog(@"the connection is used for: %@", _connection);
        return;
    }
    
//    NSLog(@"processNextUrl starting new connection");
    _currentUrl = [[_waitings anyObject] retain];
    if (!_currentUrl) {
//        NSLog(@"no url waiting.");
        return;
    }
    
    [_waitings removeObject:_currentUrl];
    _connection = [[NTLNAsyncUrlConnection alloc] initWithUrl:_currentUrl callback:self];
}

- (void) registerUrl:(NSString*)url {
    NSImage *iconInCache = [_cache objectForKey:url];
    if (iconInCache) {
        [_callback finishedToGetIcon:iconInCache forKey:url];
        return;
    } 
    if ([_waitings containsObject:url]) {
        return;
    }
    [_waitings addObject:url];
    [self processNextUrl];
}

- (void) resetConnection {
    [_currentUrl release];
    [_connection release];
    _connection = nil;
}

- (void) responseArrived:(NSData*)response statusCode:(int)code {
    NSImage *image = [[[NSImage alloc] initWithData:response] autorelease];
    if (image) {
        [_cache setObject:image forKey:_currentUrl];
    }
    [_callback finishedToGetIcon:image forKey:_currentUrl];

    [self resetConnection];
    [self processNextUrl];
}

- (void) connectionFailed:(NSError*)error  {
    NSLog(@"connectionFailed");
    [_callback failedToGetIconForKey:_currentUrl];
    [self resetConnection];
    [self processNextUrl];
}

@end
