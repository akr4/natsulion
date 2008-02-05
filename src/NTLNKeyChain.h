#import <Cocoa/Cocoa.h>


@interface NTLNKeyChain : NSObject {

}

+ (id) keychain;
- (NSString*) getPasswordForUsername:(NSString*)username;
- (BOOL) addOrUpdateWithUsername:(NSString*)username password:(NSString*)password;

@end
