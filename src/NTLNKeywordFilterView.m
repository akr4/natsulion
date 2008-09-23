// Based on NTLNFilterController.m created by mootoh on 4/30/08.
// http://blog.deadbeaf.org/2008/05/01/hack-natsulion-to-filter-messages/

#import "NTLNKeywordFilterView.h"
#import "NTLNNotification.h"
#import "NTLNColors.h"

@implementation NTLNKeywordSearchField

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

@implementation NTLNKeywordFilterView

- (void) awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(messageViewChanged:)
                                                 name:NTLN_NOTIFICATION_MESSAGE_VIEW_CHANGED
                                               object:nil];
}

- (BOOL) opened {
    return _opened;
}

- (float) defaultHeight {
    return 26;
}

- (void) applyFilter:(NSString*)filterText {
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:
                              [NSArray arrayWithObjects:
                               [NSPredicate predicateWithFormat:@"message.text like[c] %@", [NSString stringWithFormat:@"*%@*", filterText]],
                               [NSPredicate predicateWithFormat:@"message.screenName like[c] %@", [NSString stringWithFormat:@"*%@*", filterText]],
                               nil]];
//    NSLog(@"%@", [predicate description]);
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

- (void) filterInternal
{
    if ([[searchTextField stringValue] length] > 0) {
        [self applyFilter:[searchTextField stringValue]];
    } else {
        [self resetFilter];
    }
}

- (IBAction) filter:(id)sender {
    [self filterInternal];
}

- (void)drawRect:(NSRect)aRect {
    [[NSColor colorWithDeviceWhite:0.867 alpha:1.0] set];
    NSRectFill(aRect);
}

- (void) postOpen {
    _opened = TRUE;
    [[self window] makeFirstResponder:searchTextField];
    [searchTextField setupColors];
}

- (void) postClose {
    _opened = FALSE;
    //    [filterText setStringValue:@""];
    [self resignFirstResponder];
    [self resetFilter];
}


- (void) messageViewChanged:(NSNotification*)notification
{
    [self filterInternal];
}

@end
