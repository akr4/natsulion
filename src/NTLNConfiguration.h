#import <Cocoa/Cocoa.h>

#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING 0
#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_DESCENDING 1

#define NTLN_CONFIGURATION_COLOR_SCHEME_LIGHT 0
#define NTLN_CONFIGURATION_COLOR_SCHEME_DARK 1

@protocol NTLNTimelineSortOrderChangeObserver;

@interface NTLNConfiguration : NSObject {
    BOOL useGrowl;
    BOOL raiseWindowWhenNewMessageArrives;
    BOOL increaseTransparencyWhileDeactivated;
    int newMessageNotificationWindowBehavior;
    BOOL usePost;
    BOOL editWindowAlphaManually;
    BOOL decodeHeart;
    BOOL sendMessageWithEnterAndModifier;
    NSString *version;
    int refreshIntervalSeconds;
    int growlSummarizeThreshold;
    BOOL summarizeGrowl;
    BOOL autoscrollWhenNewMessageArrives;
}

@property BOOL useGrowl, usePost, editWindowAlphaManually, 
    sendMessageWithEnterAndModifier, summarizeGrowl, raiseWindowWhenNewMessageArrives, 
    increaseTransparencyWhileDeactivated, autoscrollWhenNewMessageArrives;
@property int refreshIntervalSeconds, growlSummarizeThreshold;

+ (id) instance;
- (int) timelineSortOrder;
- (void) setTimelineSortOrder:(int)sortOrder;
+ (void) setTimelineSortOrderChangeObserver:(id<NTLNTimelineSortOrderChangeObserver>)observer;
- (int) colorScheme;
- (void) setColorScheme:(int)scheme;
- (float) windowAlpha;
- (void) setWindowAlpha:(float)value;
- (NSTimeInterval) latestTimestampOfMessage;
- (void) setLatestTimestampOfMessage:(NSTimeInterval)interval;
- (float) fontSize;
- (void) setFontSize:(float)size;
- (IBAction) increaseFontSize:(id)sender;
- (IBAction) decreaseFontSize:(id)sender;
- (IBAction) resetFontSize:(id)sender;
- (BOOL) canIncreaseFontSize;
- (BOOL) canDecreaseFontSize;
- (BOOL) showMessageStatisticsOnStatusBar;
- (void) setShowMessageStatisticsOnStatusBar:(BOOL)value;

// only for IB editable binding
- (BOOL) useGrowlAndSummarizeGrowl;
- (void) setUseGrowlAndSummarizeGrowl:(BOOL)value; // not used
@end
