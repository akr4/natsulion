#import <Cocoa/Cocoa.h>
#import "AsyncUrlConnection.h"

@protocol IconCallback
- (void) finishedToGetIcon:(NSImage*)icon forKey:(NSString*)key;
- (void) failedToGetIconForKey:(NSString*)key;
@end

@interface IconRepository : NSObject <AsyncUrlConnectionCallback> {
    NSObject<IconCallback> *_callback;
    NSMutableDictionary *_cache;
    NSMutableSet *_waitings;
    
    // TODO: use connection pool
    AsyncUrlConnection *_connection;
    NSString *_currentUrl;
}
- (id) initWithCallback:(NSObject<IconCallback>*)callback;
- (void) registerUrl:(NSString*)url;
@end