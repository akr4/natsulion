#import <QuartzCore/CoreAnimation.h>
#import "TwitterStatusViewController.h"
#import "NTLNMainWindowController.h"
#import "NTLNConfiguration.h"
#import "NTLNNotification.h"

static NSImage *favoliteIcon;
static NSImage *highlightedFavoliteIcon;
static NSImage *newLightIcon;
static NSImage *newDarkIcon;
static TwitterStatusViewController *starred = nil;

@implementation TwitterStatusViewController

+ (void) initialize {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"star-normal" ofType:@"tiff"];
    favoliteIcon = [[NSImage alloc] initByReferencingFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"star-highlighted" ofType:@"tiff"];
    highlightedFavoliteIcon = [[NSImage alloc] initByReferencingFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"new-light" ofType:@"tiff"];
    newLightIcon = [[NSImage alloc] initByReferencingFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"new-dark" ofType:@"tiff"];
    newDarkIcon = [[NSImage alloc] initByReferencingFile:path];
}

- (void) fitToSuperviewWidth {
    NSRect frame = [view frame];
    frame.size.width = [_listener viewWidth];
    [view setFrame:frame];
}

- (void) setupNewIcon {
    if ([[NTLNConfiguration instance] colorScheme] == NTLN_CONFIGURATION_COLOR_SCHEME_LIGHT) {
        [newIconImageView setImage:newLightIcon];
    } else {
        [newIconImageView setImage:newDarkIcon];
    }
}

- (id) initWithTwitterStatus:(TwitterStatus*)status messageViewListener:(NSObject<NTLNMessageViewListener>*)listener {
    [super init];

    _status = status;
    [_status retain];
    
    _listener = listener;
    [_listener retain];

    [self bind:@"messageStatus"
      toObject:_status
   withKeyPath:@"status"
       options:nil];
    
    if (![NSBundle loadNibNamed: @"TwitterStatusView" owner: self]) {
        NSLog(@"unable to load Nib TwitterStatusView.nib");
    }

    [textField setViewController:self];
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
 
    [self setupNewIcon];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSchemeChanged:)
                                                 name:NTLN_NOTIFICATION_NAME_COLOR_SCHEME_CHANGED 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(colorSchemeChanged:)
                                                 name:NTLN_NOTIFICATION_NAME_WINDOW_ALPHA_CHANGED
                                               object:nil];
    
    [self unhighlight];

    return self;
}

- (NTLNMessage*) message {
    return _status;
}

- (NSView*) view {
    return view;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void) enterInScrollView {
//    NSLog(@"%s: +%@", __PRETTY_FUNCTION__, [_status screenName]);
    if ([_status status] == NTLN_MESSAGE_STATUS_READ || _markAsReadTimer) {
        return;
    }

    _markAsReadTimer = [[NSTimer scheduledTimerWithTimeInterval:2.0
                                                         target:self
                                                       selector:@selector(markAsRead)
                                                       userInfo:nil
                                                        repeats:FALSE] retain];
}

- (void) exitFromScrollView {
//    NSLog(@"%s: -%@", __PRETTY_FUNCTION__, [_status screenName]);
    if ([_status status] == NTLN_MESSAGE_STATUS_READ) {
        return;
    }
    
    [_markAsReadTimer invalidate];
    _markAsReadTimer = nil;
}

- (void) markAsRead:(bool)notification {
    //    NSLog(@"%s: =%@", __PRETTY_FUNCTION__, [_status screenName]);
    [newIconImageView setHidden:TRUE];
    [_status setStatus:NTLN_MESSAGE_STATUS_READ];
    if (notification) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NTLN_NOTIFICATION_MESSAGE_STATUS_MARKED_AS_READ object:nil];
    }
}

- (void) markAsRead {
    [self markAsRead:true];
}

- (void) highlight {
    _highlighted = TRUE;
    [view highlight];
    [textField highlight];
    [nameField highlight];
    [timestampField highlight];
    [iconView highlight];
}

- (void) unhighlight {
    _highlighted = FALSE;
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

- (void) iconViewClicked {
    [_listener replyDesiredFor:[_status screenName]];
}

- (void) markNeedCalculateHeight {
    [view markNeedCalculateHeight];
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

- (IBAction) toggleFavorite:(id)sender {
    [self showStar:TRUE];
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

- (void) startAnimation {
    [[view layer] setHidden:FALSE];
//    [view setWantsLayer:TRUE];
}

- (void) stopAnimation {
    [[view layer] setHidden:TRUE];
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
//    [view setWantsLayer:FALSE];
}

- (enum NTLNMessageStatus) messageStatus {
    return [_status status];
}

#pragma mark Notification
- (void) colorSchemeChanged:(NSNotification*)notification {
    if (_highlighted) {
        [self highlight];
    } else {
        [self unhighlight];
    }

    [self setupNewIcon];
    [view notifyColorChange];
}

@end
