#import <Cocoa/Cocoa.h>

@interface NTLNAccount : NSObject {
    NSString *_username;
    NSString *_password;
}

+ (id) instance;
+ (id) newInstance;
+ (id) newInstanceWithUsername:(NSString*)username;

- (id) initWithUsername:(NSString*)username;

- (NSString*) username;
- (NSString*) password;
- (BOOL) addOrUpdateKeyChainWithPassword:(NSString*)password;

@end


