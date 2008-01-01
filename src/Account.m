#import "Account.h"
#import "KeyChain.h"
#import "PreferencesWindow.h"

static Account *_instance;

@implementation Account

+ (id) instance {
    if (!_instance) {
        return [Account newInstance];
    }
    return _instance;
}

+ (id) newInstance {
    if (_instance) {
        [_instance release];
        _instance = nil;
    }
    
    _instance = [[Account alloc] init];
    return _instance;
}

+ (id) newInstanceWithUsername:(NSString*)username {
    if (_instance) {
        [_instance release];
        _instance = nil;
    }
    
    _instance = [[Account alloc] initWithUsername:username];

    return _instance;
}

- (id) initWithUsername:(NSString*)username {
    _username = username;
    [_username retain];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_username forKey:PREFERENCE_USERID];
    
    return self;
}

- (void) dealloc {
    [_username release];
    [_password release];
    [super dealloc];
}

- (NSString*) username {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:PREFERENCE_USERID];
}

- (NSString*) password {
    if (!_password) {
        _password = [[KeyChain keychain] getPasswordForUsername:[self username]];
    }
    return _password;
}

- (BOOL) addOrUpdateKeyChainWithPassword:(NSString*)password {
    return [[KeyChain keychain] addOrUpdateWithUsername:[self username] password:password];
}


@end
