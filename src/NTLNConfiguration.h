#import <Cocoa/Cocoa.h>

#define NTLN_NOTIFICATION_NAME_COLOR_SCHEME_CHANGED @"colorSchemeChanged"
#define NTLN_NOTIFICATION_NAME_WINDOW_ALPHA_CHANGED @"windowAlphaChanged"

#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING 0
#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_DESCENDING 1

#define NTLN_CONFIGURATION_COLOR_SCHEME_LIGHT 0
#define NTLN_CONFIGURATION_COLOR_SCHEME_DARK 1

@protocol NTLNTimelineSortOrderChangeObserver;

@interface NTLNConfiguration : NSObject {
    BOOL useGrowl;
    BOOL showWindowWhenNewMessage;
    BOOL usePost;
    BOOL editWindowAlphaManually;
    BOOL decodeHeart;
    NSString *version;
    int refreshInterval;
}

@property BOOL useGrowl, showWindowWhenNewMessage, usePost, editWindowAlphaManually, decodeHeart;
@property int refreshInterval;

+ (id) instance;
- (int) timelineSortOrder;
- (void) setTimelineSortOrder:(int)sortOrder;
+ (void) setTimelineSortOrderChangeObserver:(id<NTLNTimelineSortOrderChangeObserver>)observer;
- (int) colorScheme;
- (void) setColorScheme:(int)scheme;
- (float) windowAlpha;
- (void) setWindowAlpha:(float)value;

@end
