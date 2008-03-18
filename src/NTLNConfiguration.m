#import "NTLNConfiguration.h"
#import "NTLNMainWindowController.h"
#import "NTLNColors.h"
#import "NTLNNotification.h"

@implementation NTLNConfiguration

@synthesize useGrowl, raiseWindowWhenNewMessageArrives, increaseTransparencyWhileDeactivated, refreshIntervalSeconds,
    usePost, editWindowAlphaManually, sendMessageWithEnterAndModifier, growlSummarizeThreshold, summarizeGrowl;

static id _instance = nil;

// this should be an instance variable but I couldn't make this class a perfect singleton (override allocWithZone, copyWithZone, retain, retainCount, release, autorelease)
// due to "Controller cannot be nil" error at a boot time. Then I allow multiple instance (allow IB to instantiate this class), and make this a class variable to be shared by all instances.
static id<NTLNTimelineSortOrderChangeObserver> _timelineSortOrderChangeObserver;

+ (id) instance {
    @synchronized (self) {
        if (!_instance) {
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}

//+ (id)allocWithZone:(NSZone*)zone {
//    @synchronized(self) {
//        if (!_instance) {
//            _instance = [super allocWithZone:zone];
//            return _instance;
//        }
//    }
//    return nil;
//}
//
//- (id)copyWithZone:(NSZone*)zone {
//    return self;
//}
//
//- (id)retain {
//    return self;
//}
//
//- (unsigned)retainCount {
//    return UINT_MAX;
//}
//
//- (void)release {
//}
//
//- (id)autorelease {
//    return self;
//}

- (void) bindToProperty:(NSString*)propertyName {
    [self bind:propertyName
      toObject:[NSUserDefaultsController sharedUserDefaultsController] 
   withKeyPath:[@"values." stringByAppendingString:propertyName]
       options:nil];
}

// TODO: remove this method at 0.30 or 1.0)
- (void) migrateRefreshInterval {
    NSNumber *i = [[NSUserDefaults standardUserDefaults] objectForKey:@"refreshInterval"];
    if (i) {
        int sec = [i intValue] * 60;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:sec] forKey:@"refreshIntervalSeconds"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"refreshInterval"];
        NSLog(@"refreshInterval has been migrated to refreshIntervalSeconds:%d", sec);
    }
}

- (void) migrateConfiguration {
    [self migrateRefreshInterval];
}

- (id) init {
    [self bindToProperty:@"useGrowl"];
    [self bindToProperty:@"raiseWindowWhenNewMessageArrives"];
    [self bindToProperty:@"increaseTransparencyWhileDeactivated"];
    [self bindToProperty:@"usePost"];
    [self bindToProperty:@"editWindowAlphaManually"];
    [self bindToProperty:@"sendMessageWithEnterAndModifier"];
    [self bindToProperty:@"refreshIntervalSeconds"];
    [self bindToProperty:@"growlSummarizeThreshold"];
    [self bindToProperty:@"summarizeGrowl"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"] forKey:@"version"];
    [self migrateConfiguration];
    
    return self;
}

- (int) timelineSortOrder {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"timelineSortOrder"];
}

- (void) setTimelineSortOrder:(int)sortOrder {
    [[NSUserDefaults standardUserDefaults] setInteger:sortOrder forKey:@"timelineSortOrder"];
    [_timelineSortOrderChangeObserver timelineSortOrderChangeObserverSortOrderChanged];
}

+ (void) setTimelineSortOrderChangeObserver:(id<NTLNTimelineSortOrderChangeObserver>)observer {
    _timelineSortOrderChangeObserver = observer;
}

- (float) windowAlpha {
//    NSLog(@"%s: %f", __PRETTY_FUNCTION__, [[NSUserDefaults standardUserDefaults] floatForKey:@"windowTransparency"]);
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"windowAlpha"];
}

- (void) setWindowAlpha:(float)value {
//    NSLog(@"%s: %f", __PRETTY_FUNCTION__, value);
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"windowAlpha"];
    [[NTLNColors instance] notifyConfigurationChange];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_WINDOW_ALPHA_CHANGED object:nil];
}

- (int) colorScheme {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"colorScheme"];
}

- (void) setColorScheme:(int)scheme {
    [[NSUserDefaults standardUserDefaults] setInteger:scheme forKey:@"colorScheme"];
    [[NTLNColors instance] notifyConfigurationChange];
    if (!editWindowAlphaManually) {
        if (scheme == NTLN_CONFIGURATION_COLOR_SCHEME_LIGHT) {
            [self setWindowAlpha:NTLN_COLORS_LIGHT_SCHEME_DEFAULT_ALPHA];
        } else {
            [self setWindowAlpha:NTLN_COLORS_DARK_SCHEME_DEFAULT_ALPHA];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_COLOR_SCHEME_CHANGED object:nil];
}

- (NSTimeInterval) latestTimestampOfMessage {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"latestTimestampOfMessage"];
}

- (void) setLatestTimestampOfMessage:(NSTimeInterval)interval {
    [[NSUserDefaults standardUserDefaults] setFloat:interval forKey:@"latestTimestampOfMessage"];
}

- (BOOL) useGrowlAndSummarizeGrowl {
    return useGrowl && summarizeGrowl;
}

- (void) setUseGrowlAndSummarizeGrowl:(BOOL)value {
    
}

#pragma mark Font
#define MAX_FONT_SIZE 32
#define MIN_FONT_SIZE 9

- (void) setFontSize:(float)size {
    [[NSUserDefaults standardUserDefaults] setFloat:size forKey:@"fontSize"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_FONT_SIZE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_FONT_SIZE_CHANGED2 object:nil];
}

- (float) fontSize {
    float size = [[NSUserDefaults standardUserDefaults] floatForKey:@"fontSize"];
    if (size == 0.0) {
        size = [NSFont systemFontSize];
        [self setFontSize:size];
    }
    return size;
}

- (IBAction) increaseFontSize:(id)sender {
    float fontSize = [self fontSize];
    fontSize += (fontSize >= 14 ? 2 : 1);
    if (fontSize > MAX_FONT_SIZE) {
        fontSize = MAX_FONT_SIZE;
    }
    [self setFontSize:fontSize];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_FONT_SIZE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_FONT_SIZE_CHANGED2 object:nil];
}

- (IBAction) decreaseFontSize:(id)sender {
    float fontSize = [self fontSize];
    fontSize -= (fontSize >= 16 ? 2 : 1);
    if (fontSize < MIN_FONT_SIZE) {
        fontSize = MIN_FONT_SIZE;
    }
    [self setFontSize:fontSize];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_FONT_SIZE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_FONT_SIZE_CHANGED2 object:nil];
}

- (IBAction) resetFontSize:(id)sender {
    [self setFontSize:[NSFont systemFontSize]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_FONT_SIZE_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_FONT_SIZE_CHANGED2 object:nil];
}

- (BOOL) canIncreaseFontSize {
    return [self fontSize] < MAX_FONT_SIZE;
}

- (BOOL) canDecreaseFontSize {
    return [self fontSize] > MIN_FONT_SIZE;
}

- (BOOL) showMessageStatisticsOnStatusBar {
    return [[NSUserDefaults standardUserDefaults] floatForKey:@"showMessageStatisticsOnStatusBar"];
}

- (void) setShowMessageStatisticsOnStatusBar:(BOOL)value {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:@"showMessageStatisticsOnStatusBar"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_STATISTICS_DISPLAY_SETTING_CHANGED
                                                        object:[NSNumber numberWithBool:value]];
}

@end
