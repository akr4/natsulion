#import <Cocoa/Cocoa.h>

@protocol NTLNAsyncUrlConnectionCallback 
- (void) responseArrived:(NSData*)response statusCode:(int)code;
- (void) connectionFailed:(NSError*)error;
@end

@interface NTLNAsyncUrlConnection : NSObject {
    NSObject<NTLNAsyncUrlConnectionCallback> *_callback;
    NSURLConnection *_connection;
    NSMutableData *_receivedData;
    int _statusCode;
    NSString *_username;
    NSString *_password;
    BOOL _finished;
}
- (id) initWithUrl:(NSString*)url callback:(NSObject<NTLNAsyncUrlConnectionCallback>*)callback;
- (id) initWithUrl:(NSString*)url username:(NSString*)username password:(NSString*)password usePost:(BOOL)post callback:(NSObject<NTLNAsyncUrlConnectionCallback>*)callback;
- (id) initPostConnectionWithUrl:(NSString*)url bodyString:(NSString*)bodyString username:(NSString*)username password:(NSString*)password callback:(NSObject<NTLNAsyncUrlConnectionCallback>*)callback;
- (BOOL) isFinished;
@end
