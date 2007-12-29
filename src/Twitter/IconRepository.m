#import "IconRepository.h"


@implementation IconRepository

- (id) initWithCallback:(NSObject<IconCallback>*)callback {
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
    [super dealloc];
}

- (void) processNextUrl {
    NSLog(@"processNextUrl");
    if (_connection != nil) {
        NSLog(@"the connection is used for: %@", _connection);
        return;
    }
    
    NSLog(@"processNextUrl starting new connection");
    _currentUrl = [[_waitings anyObject] retain];
    if (!_currentUrl) {
        NSLog(@"no url waiting.");
        return;
    }
    
    [_waitings removeObject:_currentUrl];
    _connection = [[AsyncUrlConnection alloc] initWithUrl:_currentUrl andCallback:self];
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

- (void) responseArrived:(NSData*)response {
    NSImage *image = [[[NSImage alloc] initWithData:response] autorelease];
    [_cache setObject:image forKey:_currentUrl];
    [_callback finishedToGetIcon:image forKey:_currentUrl];

    [self resetConnection];
    [self processNextUrl];
}

- (void) connectionFailed {
    NSLog(@"connectionFailed");
    [_callback failedToGetIconForKey:_currentUrl];
    [self resetConnection];
    [self processNextUrl];
}

@end
