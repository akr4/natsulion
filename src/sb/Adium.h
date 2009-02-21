/*
 * Adium.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class AdiumApplication, AdiumService, AdiumWindow, AdiumChatWindow, AdiumChat, AdiumAccount, AdiumContactGroup, AdiumContact, AdiumStatus, AdiumRichText, AdiumCharacter, AdiumParagraph, AdiumWord, AdiumAttributeRun, AdiumAttachment;

typedef enum {
	AdiumStatusTypesOffline = 'Soff' /* Account is offline. */,
	AdiumStatusTypesAvailable = 'Sonl' /* Account is online. */,
	AdiumStatusTypesAway = 'Sawy' /* Account is away. */,
	AdiumStatusTypesInvisible = 'Sinv' /* Account is invisible. */
} AdiumStatusTypes;

typedef enum {
	AdiumProxyTypesHTTPProxy = 'HTTP' /* An HTTP proxy. */,
	AdiumProxyTypesSOCKS4Proxy = 'SCK4' /* A SOCKS 4 proxy. */,
	AdiumProxyTypesSOCKS5Proxy = 'SCK5' /* A SOCKS 5 proxy. */,
	AdiumProxyTypesDefaultHTTPProxy = 'DHTP' /* The system-wide HTTP proxy. */,
	AdiumProxyTypesDefaultSOCKS4Proxy = 'DSK4' /* The system-wide SOCKS4 proxy. */,
	AdiumProxyTypesDefaultSOCKS5Proxy = 'DSK5' /* The system-wide SOCKS5 proxy. */,
	AdiumProxyTypesNoProxy = 'NONE' /* No proxy configured. */
} AdiumProxyTypes;



/*
 * Adium Suite
 */

// Adium's application class
@interface AdiumApplication : SBApplication

- (SBElementArray *) accounts;
- (SBElementArray *) contacts;
- (SBElementArray *) contactGroups;
- (SBElementArray *) services;
- (SBElementArray *) windows;
- (SBElementArray *) chatWindows;
- (SBElementArray *) chats;
- (SBElementArray *) statuses;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy, readonly) NSString *version;  // The version of the application.
@property (copy, readonly) AdiumChat *activeChat;  // The frontmost chat.
@property (copy) AdiumStatus *globalStatus;  // The global status. This is the status that the most online accounts are currently using; it will only be an offline status if no accounts are online. Setting it changes the status for all accounts.

- (void) GetURL:(NSString *)x;  // Tells Adium to open the specified chat, in URL form

@end

// An Adium service (a.k.a. chat protocol)
@interface AdiumService : SBObject

- (SBElementArray *) accounts;

@property (copy, readonly) NSString *name;  // The name of the service.
@property (copy, readonly) NSImage *image;  // The image associated with this service.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// A window in Adium
@interface AdiumWindow : SBObject

@property (copy, readonly) NSString *name;  // The title of this window
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Whether the window has a close box.
@property (readonly) BOOL minimizable;  // Whether the window can be minimized.
@property BOOL minimized;  // Whether the window is currently minimized.
@property (readonly) BOOL resizable;  // Whether the window can be resized.
@property BOOL visible;  // Whether the window is currently visible.
@property (readonly) BOOL zoomable;  // Whether the window can be zoomed.
@property BOOL zoomed;  // Whether the window is currently zoomed.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// A window that contains chats
@interface AdiumChatWindow : AdiumWindow

- (SBElementArray *) chats;


@end

// A chat in Adium
@interface AdiumChat : SBObject

- (SBElementArray *) contacts;

@property (copy, readonly) NSString *name;  // The name of the chat
@property (copy, readonly) NSString *ID;  // The unique identifier of the chat.
@property (copy, readonly) AdiumAccount *account;  // The account associated with this chat
@property (copy, readonly) NSDate *dateOpened;  // The date and time at which this chat was opened
@property (readonly) NSInteger index;  // The index of this tab in the chat window
@property (copy, readonly) AdiumWindow *window;  // The window this chat is in
@property (readonly) NSInteger unreadMessageCount;  // The number of unread messages for this chat

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) sendMessage:(NSString *)message withFile:(NSURL *)withFile;  // Send text or a file to some contact.

@end

// An account in Adium
@interface AdiumAccount : SBObject

- (SBElementArray *) contacts;

- (NSInteger) id;  // The unique ID associated with this account
@property (copy, readonly) NSString *name;  // The name of this account
@property (copy) NSString *displayName;  // The display name of this account
@property (copy, readonly) AdiumService *service;  // The service this account is registered under
@property (readonly) BOOL enabled;  // Whether or not this account is enabled
@property (copy, readonly) NSString *host;  // The host this account is connected to
@property (readonly) NSInteger port;  // The port this account is connected to
@property (copy) AdiumStatus *status;  // The current status on the account.
@property AdiumStatusTypes statusType;  // The type of the current status. Setting this creates a temporary status.
@property (copy) AdiumRichText *statusMessage;  // The message associated with the current status. Setting this creates a temporary status.
@property (copy) NSImage *image;  // The image associated with this account.
@property BOOL proxyEnabled;  // Whether or not a proxy is enabled for this account.
@property AdiumProxyTypes proxyType;  // The type of this proxy.
@property (copy) NSString *proxyHost;  // The proxy host.
@property NSInteger proxyPort;  // The port that should be used to connect to the proxy.
@property (copy) NSString *proxyUsername;  // The username that should be used to connect to the proxy.
@property (copy) NSString *proxyPassword;  // The password that should be used to connect to the proxy.

- (void) close;  // Close a document.
- (void) goOnlineWithMessage:(AdiumRichText *)withMessage;  // Changes the status of an account.
- (void) goAvailableWithMessage:(AdiumRichText *)withMessage;  // Changes the status of an account.
- (void) goOfflineWithMessage:(AdiumRichText *)withMessage;  // Changes the status of an account.
- (void) goAwayWithMessage:(AdiumRichText *)withMessage;  // Changes the status of an account.
- (void) goInvisibleWithMessage:(AdiumRichText *)withMessage;  // Changes the status of an account.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// A contact group
@interface AdiumContactGroup : SBObject

- (SBElementArray *) contacts;

@property (copy) NSString *name;  // The name of this contact group.
@property (readonly) BOOL visible;  // The visibility of this group.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// A contact
@interface AdiumContact : SBObject

@property (copy, readonly) AdiumAccount *account;  // The account associated with this contact
@property (copy, readonly) AdiumContactGroup *group;  // The group associated with this contact
@property (copy, readonly) NSString *name;  // The name of this contact
@property (copy, readonly) NSString *ID;  // The opaque unique identifier of the contact
@property (copy) NSString *displayName;  // The display name or alias associated with this contact.
@property (copy) NSString *notes;  // The user-defined notes for this contact.
@property (readonly) NSInteger idleTime;  // The time this contact has been idle.
@property (readonly) AdiumStatusTypes statusType;  // The current status of this contact
@property (copy, readonly) AdiumRichText *statusMessage;  // The custom status message for this contact.
@property (copy) NSImage *image;  // The image associated with this contact.
@property BOOL blocked;  // Whether or not this contact is marked as blocked.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// A saved status in Adium
@interface AdiumStatus : SBObject

@property (copy) NSString *title;  // The title of the status.
@property AdiumStatusTypes statusType;  // The type of this status.
@property (copy) AdiumRichText *statusMessage;  // The custom status message.
@property (copy) AdiumRichText *autoreply;  // The message to auto reply
- (NSInteger) id;  // The unique ID of the status
@property BOOL saved;  // Whether this status is temporary or not

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end



/*
 * Text Suite
 */

// Rich (styled) text
@interface AdiumRichText : SBObject

- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) attachments;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// This subdivides the text into characters.
@interface AdiumCharacter : SBObject

- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) attachments;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// This subdivides the text into paragraphs.
@interface AdiumParagraph : SBObject

- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) attachments;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// This subdivides the text into words.
@interface AdiumWord : SBObject

- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) attachments;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// This subdivides the text into chunks that all have the same attributes.
@interface AdiumAttributeRun : SBObject

- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) attachments;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.

- (void) close;  // Close a document.
- (void) delete;  // Delete an object.
- (BOOL) exists;  // Verify if an object exists.
- (SBObject *) moveTo:(SBObject *)to;  // Move object(s) to a new location.

@end

// Represents an inline text attachment. This class is used mainly for make commands.
@interface AdiumAttachment : AdiumRichText

@property (copy) NSString *fileName;  // The path to the file for the attachment


@end

