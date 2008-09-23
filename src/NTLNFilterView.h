#import <Cocoa/Cocoa.h>

@class NTLNMessageListViewsController;
@class NTLNMessageTableViewController;
@class NTLNKeywordFilterView;
@class NTLNScreenNameFilterView;

@protocol NTLNFilterViewContent
- (void) filter;
- (void) filterByQuery:(id)query;
- (void) postOpen;
- (void) postClose;
@end

@interface NTLNFilterView : NSBox {
    IBOutlet NTLNMessageListViewsController *messageListViewsController;
    IBOutlet NTLNMessageTableViewController *messageTableViewController;
    IBOutlet NTLNKeywordFilterView *keywordFilterView;
    IBOutlet NTLNScreenNameFilterView *screenNameFilterView;

    NSView<NTLNFilterViewContent> *contentFilterView;
    BOOL _opened;
}

- (IBAction) filter:(id)sender;

// object: nil means to use current text
- (void) filterByQuery:(id)query;

- (float) defaultHeight;
- (BOOL) opened;
- (void) postOpen;
- (void) postClose;
- (void) changeContentToKeywordSearch;
- (void) changeContentToScreenNameSearch;

@end
