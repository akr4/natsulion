#import <Cocoa/Cocoa.h>

@protocol AsyncUrlConnectionCallback 
- (void) responseArrived:(NSData*)response;
- (void) connectionFailed;
@end

@interface AsyncUrlConnection : NSObject {
    NSObject<AsyncUrlConnectionCallback> *_callback;
    NSMutableData *_recievedData;
}
- (id) initWithUrl:(NSString*)url andCallback:(NSObject<AsyncUrlConnectionCallback>*)callback;
- (id) initPostConnectionWithUrl:(NSString*)url andBodyString:(NSString*)bodyString andCallback:(NSObject<AsyncUrlConnectionCallback>*)callback;
@end
