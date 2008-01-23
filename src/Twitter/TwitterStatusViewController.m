#import "TwitterStatusViewController.h"
#import "MainWindowController.h"

static NSImage *favoliteIcon;
static NSImage *highlightedFavoliteIcon;
static TwitterStatusViewController *starred = nil;

@implementation TwitterStatusViewController

+ (void) initialize {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"star-normal" ofType:@"png"];
    favoliteIcon = [[NSImage alloc] initByReferencingFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"star-highlighted" ofType:@"png"];
    highlightedFavoliteIcon = [[NSImage alloc] initByReferencingFile:path];
}

- (void) fitToSuperviewWidth {
    NSRect frame = [view frame];
    frame.size.width = [_listener viewWidth];
    [view setFrame:frame];
}

- (id) initWithTwitterStatus:(TwitterStatus*)status messageViewListener:(NSObject<MessageViewListener>*)listener {
    [super init];

    _status = status;
    [_status retain];
    
    _listener = listener;
    [_listener retain];
    
    if (![NSBundle loadNibNamed: @"TwitterStatusView" owner: self]) {
        NSLog(@"unable to load Nib TwitterStatusView.nib");
    }
    [textField setMessage:[status text]];
    [nameField setStatus:_status];
    [timestampField setStatus:_status];
    [iconView setStatus:_status];
    [iconView setViewController:self];
    
    [favoliteButton setImage:favoliteIcon];
    [favoliteButton setHidden:TRUE];
    
    [self fitToSuperviewWidth];
    [view setViewController:self];
    [view setTwitterStatus:_status];

    return self;
}

- (Message*) message {
    return _status;
}

- (NSView*) view {
    return view;
}

- (void) dealloc {
    [_status release];
    [_listener release];
    [textField removeFromSuperview];
    [nameField removeFromSuperview];
    [iconView removeFromSuperview];
    [timestampField removeFromSuperview];
    [view removeFromSuperview];
    [view release];
    [super dealloc];
}

- (NSTextField*) nameField {
    return nameField;
}

- (BOOL) isEqual:(id)anObject {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
	if (anObject == self)
        return TRUE;
	if (!anObject || ![anObject isKindOfClass:[self class]])
        return FALSE;
    return [[self message] isEqual:[(TwitterStatusViewController*)anObject message]];
}
     
- (void) highlight {
    [view highlight];
    [textField highlight];
    [nameField highlight];
    [timestampField highlight];
    [iconView highlight];
}

- (void) unhighlight {
    [view unhighlight];
    [textField unhighlight];
    [nameField unhighlight];
    [timestampField unhighlight];
    [iconView unhighlight];
}

- (float) requiredHeight {
    [self fitToSuperviewWidth];
    return [view requiredHeight];
}

- (NSDate*) timestamp {
    return [_status timestamp];
}

- (void) iconViewClicked {
    [_listener replyDesiredFor:[_status screenName]];
}

- (void) markNeedCalculateHeight {
    [view markNeedCalculateHeight];
}

- (IBAction) toggleFavorite:(id)sender {
    [favoliteButton setEnabled:FALSE];
    _favoriteIsCreating = TRUE;
    [_listener createFavoriteDesiredFor:[_status statusId]];
}

- (void) favoriteCreated {
    [favoliteButton setImage:highlightedFavoliteIcon];
    _starHighlighted = TRUE;
    _favoriteIsCreating = FALSE;
}

- (void) favoriteCreationFailed {
    [favoliteButton setEnabled:TRUE];
    _favoriteIsCreating = FALSE;
}

- (void) showStar:(BOOL)show {
    if (!_starHighlighted && !_favoriteIsCreating && ![_listener isCreatingFavoriteWorking]) {
        if (show) {
            [starred showStar:FALSE];
            starred = self;
        }
        [favoliteButton setHidden:!show];
    }
}

@end
