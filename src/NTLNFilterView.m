#import "NTLNFilterView.h"

#import "NTLNKeywordFilterView.h"
#import "NTLNScreenNameFilterView.h"
#import "NTLNNotification.h"
#import "NTLNColors.h"

@implementation NTLNFilterView

- (void) awakeFromNib
{
    [self setTitlePosition:NSNoTitle];
    [self setBoxType:NSBoxPrimary];
    [self setBorderType:NSNoBorder];
    [self setContentViewMargins:NSZeroSize];
    
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

- (IBAction) filter:(id)sender {
    [contentFilterView filter];
}

- (void) filterByQuery:(id)query
{
    [contentFilterView filterByQuery:query];
}

- (void) postOpen {
    _opened = TRUE;
    [contentFilterView postOpen];
}

- (void) postClose {
    _opened = FALSE;
    [contentFilterView postClose];
}

- (void) changeContentToKeywordSearch
{
    contentFilterView = keywordFilterView;
    [self setContentView:contentFilterView];
}

- (void) changeContentToScreenNameSearch
{
    contentFilterView = screenNameFilterView;
    [self setContentView:contentFilterView];
}

- (void) messageViewChanged:(NSNotification*)notification
{
    if (_opened) {
        [self filter:self];
    }
}

@end
