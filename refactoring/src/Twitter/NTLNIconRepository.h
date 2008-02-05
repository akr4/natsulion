#import <Cocoa/Cocoa.h>
#import "NTLNAsyncUrlConnection.h"

@protocol NTLNIconCallback
- (void) finishedToGetIcon:(NSImage*)icon forKey:(NSString*)key;
- (void) failedToGetIconForKey:(NSString*)key;
@end

@interface NTLNIconRepository : NSObject <NTLNAsyncUrlConnectionCallback> {
    NSObject<NTLNIconCallback> *_callback;
    NSMutableDictionary *_cache;
    NSMutableSet *_waitings;
    
    // TODO: use connection pool
    NTLNAsyncUrlConnection *_connection;
    NSString *_currentUrl;
}
- (id) initWithCallback:(NSObject<NTLNIconCallback>*)callback;
- (void) registerUrl:(NSString*)url;
@end