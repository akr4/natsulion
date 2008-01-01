#import "KeyChain.h"

#define SERVER_NAME "twitter.com"
#define SERVER_PORT 80

@implementation KeyChain

+ (id) keychain {
    return [[[KeyChain alloc] init] autorelease];
}


// return nil if error
- (NSString*) getPasswordForUsername:(NSString*)username {
    
    if (username == nil || [username length] == 0) {
        NSLog(@"no username specified.");
        return nil;
    }
    
    UInt32 len;
    char *password;
    
    OSStatus status = SecKeychainFindInternetPassword (
                                                       NULL,
                                                       strlen(SERVER_NAME),
                                                       SERVER_NAME,
                                                       0,
                                                       NULL,
                                                       strlen([username UTF8String]),
                                                       [username UTF8String],
                                                       0,
                                                       NULL,
                                                       SERVER_PORT,
                                                       kSecProtocolTypeHTTP,
                                                       kSecAuthenticationTypeDefault,
                                                       &len,
                                                       (void**) &password,
                                                       NULL
                                                       );
    
    if (status != 0) {
        NSLog(@"getPasswordForUsername:%@ error: internal code=%d", username, status);
        return nil;
    }
    
    
    char *cstring = (char*)malloc(len + 1);
    memcpy(cstring, password, len);
    cstring[len] = '\0';
    
    NSString *back = [NSString stringWithCString:cstring];
    
    free(cstring);
    SecKeychainItemFreeContent (NULL, password);
    
    return back;
}

- (BOOL) addOrUpdateWithUsername:(NSString*)username password:(NSString*)password {
    
    SecKeychainItemRef itemRef;
    OSStatus status;
    
    status = SecKeychainFindInternetPassword (
                                              NULL,
                                              strlen(SERVER_NAME),
                                              SERVER_NAME,
                                              0,
                                              NULL,
                                              strlen([username UTF8String]),
                                              [username UTF8String],
                                              0,
                                              NULL,
                                              SERVER_PORT,
                                              kSecProtocolTypeHTTP,
                                              kSecAuthenticationTypeDefault,
                                              0,
                                              NULL,
                                              &itemRef
                                              );
    
    
    if (status == 0) {
        status = SecKeychainItemModifyAttributesAndData ( 
                                                         itemRef,
                                                         NULL,
                                                         strlen([password UTF8String]),
                                                         [password UTF8String]
                                                         );
        
        CFRetain(itemRef);
        
        if (status != 0) {
            NSLog(@"addOrUpdateWithUsername:%@ modify passowrd error: internal code=%d", username, status);
            return FALSE;
        }
        
        
    } else if (status == errSecItemNotFound) {
        status = SecKeychainAddInternetPassword(NULL, 
                                                strlen(SERVER_NAME),
                                                SERVER_NAME,
                                                0,
                                                NULL,
                                                strlen([username UTF8String]),
                                                [username UTF8String],
                                                0,
                                                NULL,
                                                SERVER_PORT,
                                                kSecProtocolTypeHTTP,
                                                kSecAuthenticationTypeDefault,
                                                strlen([password UTF8String]),
                                                [password UTF8String],
                                                NULL);
        
        if (status != 0) {
            NSLog(@"addOrUpdateWithUsername:%@ add passowrd error: internal code=%d", username, status);
            return FALSE;
        }
        
    } else {
        NSLog(@"addOrUpdateWithUsername:%@ find passowrd error: internal code=%d", username, status);
        return FALSE;
    }
    
    return TRUE;
}
@end
