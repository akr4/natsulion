#import <Cocoa/Cocoa.h>

#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_ASCENDING 0
#define NTLN_CONFIGURATION_TIMELINE_SORT_ORDER_DESCENDING 1

@protocol NTLNTimelineSortOrderChangeObserver;

@interface NTLNConfiguration : NSObject {
    BOOL useGrowl;
    BOOL showWindowWhenNewMessage;
    BOOL alwaysExpandMessage;
    BOOL usePost;
    int refreshInterval;
    int timelineSortOrder;
    float windowTransparency;
}

@property BOOL useGrowl, showWindowWhenNewMessage, alwaysExpandMessage, usePost;
@property int refreshInterval;
@property float windowTransparency;

+ (id) instance;
- (int) timelineSortOrder;
- (void) setTimelineSortOrder:(int)sortOrder;
+ (void) setTimelineSortOrderChangeObserver:(id<NTLNTimelineSortOrderChangeObserver>)observer;

@end
