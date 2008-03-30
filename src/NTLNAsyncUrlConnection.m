#import "NTLNAsyncUrlConnection.h"

@implementation NTLNAsyncUrlConnection

- (void) initInternalWithUsername:(NSString*)username password:(NSString*)password {
    _username = username;
    [_username retain];
    _password = password;
    [_password retain];
    _finished = FALSE;
}

- (id) initWithUrl:(NSString*)url usePost:(BOOL)post callback:(NSObject<NTLNAsyncUrlConnectionCallback>*)callback {
    [self initInternalWithUsername:nil password:nil];
    
    NSString *encodedUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
    NSLog(@"sending request to %@", encodedUrl);
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:encodedUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setTimeoutInterval:5.0];
    [request setHTTPShouldHandleCookies:FALSE];
    if (post) {
        [request setHTTPMethod:@"POST"];
    }
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!_connection) {
        NSLog(@"failed to get connection.");
        return nil;
    }
    
    _callback = callback;
    _recievedData = [[NSMutableData alloc] init];
    return self;
}

- (id) initWithUrl:(NSString*)url callback:(NSObject<NTLNAsyncUrlConnectionCallback>*)callback {
    return [self initWithUrl:url usePost:FALSE callback:callback];
}

- (id)initWithUrl:(NSString*)url username:(NSString*)username password:(NSString*)password usePost:(BOOL)post callback:(NSObject<NTLNAsyncUrlConnectionCallback>*)callback {
    [self initInternalWithUsername:username password:password];
    NSMutableString* url2 = [[url mutableCopy] autorelease];
    [url2 insertString:[NSString stringWithFormat:@"%@:%@@", username, password] atIndex:7];
    return [self initWithUrl:url2 usePost:FALSE callback:callback];
}

- (id) initPostConnectionWithUrl:(NSString*)url bodyString:(NSString*)bodyString username:(NSString*)username password:(NSString*)password callback:(NSObject<NTLNAsyncUrlConnectionCallback>*)callback {
    [self initInternalWithUsername:username password:password];

    NSMutableString* url2 = [[url mutableCopy] autorelease];
    [url2 insertString:[NSString stringWithFormat:@"%@:%@@", username, password] atIndex:7];
    
    NSString *encodedUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url2, NULL, NULL, kCFStringEncodingUTF8);
    NSLog(@"sending post request to %@", encodedUrl);

    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:encodedUrl]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setTimeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPShouldHandleCookies:FALSE];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!_connection) {
        NSLog(@"failed to get connection.");
        return nil;
    }
    
    _callback = callback;
    _recievedData = [[NSMutableData alloc] init];
    return self;
}

- (void) dealloc {
//    NSLog(@"AsyncUrlConnection#dealloc: %@ (%x)", self, self);
    [_recievedData release];
    [_connection release];
    [_username release];
    [_password release];
//    [super dealloc]; // should be called but a user has experienced a crash with this line.
}

- (BOOL) isFinished {
    return _finished;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    _statusCode = [httpResponse statusCode];
//    NSLog(@"receiving response... status code = %d", statusCode);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_recievedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _finished = TRUE;
    [_callback responseArrived:_recievedData statusCode:_statusCode];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*) error {
    NSLog(@"connection:didFailWithError - %@ - %d - %@", [error localizedFailureReason], [error code], [error description]);
    _finished = TRUE;
    [_callback connectionFailed:error];
}

-(void)connection:(NSURLConnection*)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge { 
      NSLog(@"authentication error");
      [[challenge sender] cancelAuthenticationChallenge:challenge]; 
//
//    if ([challenge previousFailureCount] == 0) { 
//        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:_username password:_password persistence:NSURLCredentialPersistenceNone]; 
//        NSLog([newCredential description]);
//        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge]; 
//    } else { 
//        NSLog(@"authentication failure");
//        // TODO: should be "real" code
////        _statusCode = 401;
//        [[challenge sender] cancelAuthenticationChallenge:challenge]; 
//    } 
}    
@end