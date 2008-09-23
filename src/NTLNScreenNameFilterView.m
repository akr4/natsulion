#import "NTLNScreenNameFilterView.h"
#import "NTLNMessageListViewsController.h"
#import "NTLNMessageTableViewController.h"
#import "NTLNNotification.h"
#import "NTLNColors.h"

@implementation NTLNScreenNameSearchField

- (void) setupColors {
    [(NSTextView*)[[self window] fieldEditor:TRUE forObject:self] setInsertionPointColor:[NSColor blackColor]];
}

- (BOOL)becomeFirstResponder {
    [self setupColors];
    return [super becomeFirstResponder];
}

- (void) awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSettingChanged:)
                                                 name:NTLN_NOTIFICATION_COLOR_SCHEME_CHANGED 
                                               object:nil];
}

- (void) colorSettingChanged:(NSNotification*)notification {
    [self setupColors];
}

@end

@implementation NTLNScreenNameFilterView

- (void) applyFilter:(NSString*)filterText {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"message.screenName in[c] %@", filterText];
    [messageListViewsController addAuxiliaryPredicate:predicate];
    [messageListViewsController applyCurrentPredicate];
    [messageTableViewController reloadTableView];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_KEYWORD_FILTER_APPLIED object:nil];
}

- (void) resetFilter {
    [messageListViewsController resetAuxiliaryPredicate];
    [messageListViewsController applyCurrentPredicate];
	[messageTableViewController reloadTableView];
    [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_KEYWORD_FILTER_APPLIED object:nil];
}

- (void) filter
{
    if ([[searchTextField stringValue] length] > 0) {
        [self applyFilter:[searchTextField stringValue]];
    } else {
        [self resetFilter];
    }
}

- (IBAction) filter:(id)sendar
{
    [self filter];
}

- (void) filterByQuery:(id)query
{
    if (query) {
        [searchTextField setObjectValue:query];
    }
    [self filter];
}

- (void)drawRect:(NSRect)aRect {
    [[NSColor colorWithDeviceWhite:0.867 alpha:1.0] set];
    NSRectFill(aRect);
}

- (void) postOpen {
//    [[self window] makeFirstResponder:searchTextField];
    [searchTextField setupColors];
}

- (void) postClose {
//    [self resignFirstResponder];
    [self resetFilter];
}

#pragma mark -
#pragma mark NSTokenField delegate methods
- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject
{
    return [@"@" stringByAppendingString:representedObject];
}

@end
