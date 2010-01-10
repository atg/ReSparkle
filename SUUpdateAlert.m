//
//  SUUpdateAlert.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/12/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "SUUpdateAlert.h"

#import "SUHost.h"
#import "SUReleaseNotesViewController.h"
#import <WebKit/WebKit.h>

@implementation SUUpdateAlert

- (id)initWithAppcastItem:(SUAppcastItem *)item host:(SUHost *)aHost
{
	self = [super initWithHost:host windowNibName:@"SUUpdateAlert"];
	if (self)
	{
		host = [aHost retain];
		updateItem = [item retain];
		
		releaseNotesViewController = [[SUReleaseNotesViewController alloc] init];
		
		[self setShouldCascadeWindows:NO];
	}
	return self;
}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], [host bundlePath]]; }

- (void)dealloc
{
	[releaseNotesViewController release];
	[updateItem release];
	[host release];
	[super dealloc];
}

- (void)endWithSelection:(SUUpdateAlertChoice)choice
{
	[releaseNotesViewController end];
	
	[self close];
	if ([delegate respondsToSelector:@selector(updateAlert:finishedWithChoice:)])
		[delegate updateAlert:self finishedWithChoice:choice];
}

- (IBAction)installUpdate:sender
{
	[self endWithSelection:SUInstallUpdateChoice];
}

- (IBAction)skipThisVersion:sender
{
	[self endWithSelection:SUSkipThisVersionChoice];
}

- (IBAction)remindMeLater:sender
{
	[self endWithSelection:SURemindMeLaterChoice];
}

- (void)displayReleaseNotes
{
	[releaseNotesViewController displayReleaseNotes];
}

- (BOOL)showsReleaseNotes
{
	NSNumber *shouldShowReleaseNotes = [host objectForInfoDictionaryKey:SUShowReleaseNotesKey];
	if (shouldShowReleaseNotes == nil)
		return YES; // defaults to YES
	else
		return [shouldShowReleaseNotes boolValue];
}

- (BOOL)allowsAutomaticUpdates
{
	if (![host objectForInfoDictionaryKey:SUAllowsAutomaticUpdatesKey])
		return YES; // defaults to YES
	return [host boolForInfoDictionaryKey:SUAllowsAutomaticUpdatesKey];
}

- (void)awakeFromNib
{	
	[[self window] setLevel:NSFloatingWindowLevel];
		
	// We're gonna do some frame magic to match the window's size to the description field and the presence of the release notes view.
	NSRect frame = [[self window] frame];
	
	if ([self showsReleaseNotes])
	{
		releaseNotesViewController.webView = releaseNotesView;
		releaseNotesViewController.webViewBox = (NSBox *)[releaseNotesView superview];
		releaseNotesViewController.updateItem = updateItem;
	}
	else if (![self showsReleaseNotes])
	{
		// Resize the window to be appropriate for not having a huge release notes view.
		frame.size.height -= [releaseNotesView frame].size.height + 40; // Extra 40 is for the release notes label and margin.
		[[self window] setShowsResizeIndicator:NO];
	}
	
	if (![self allowsAutomaticUpdates])
	{
		NSRect boxFrame = [[[releaseNotesView superview] superview] frame];
		boxFrame.origin.y -= 20;
		boxFrame.size.height += 20;
		[[[releaseNotesView superview] superview] setFrame:boxFrame];
	}
	
	[[self window] setFrame:frame display:NO];
	[[self window] center];
	
	if ([self showsReleaseNotes])
	{
		[self displayReleaseNotes];
	}
}

- (BOOL)windowShouldClose:note
{
	[self endWithSelection:SURemindMeLaterChoice];
	return YES;
}

- (NSImage *)applicationIcon
{
	return [host icon];
}

- (NSString *)titleText
{
	return [NSString stringWithFormat:SULocalizedString(@"A new version of %@ is available!", nil), [host name]];
}

- (NSString *)descriptionText
{
	NSString *updateItemVersion = [updateItem displayVersionString];
    NSString *hostVersion = [host displayVersion];
	// Display more info if the version strings are the same; useful for betas.
    if ([updateItemVersion isEqualToString:hostVersion])
	{
        updateItemVersion = [updateItemVersion stringByAppendingFormat:@" (%@)", [updateItem versionString]];
        hostVersion = [hostVersion stringByAppendingFormat:@" (%@)", [host version]];
    }
    return [NSString stringWithFormat:SULocalizedString(@"%@ %@ is now available--you have %@. Would you like to download it now?", nil), [host name], updateItemVersion, hostVersion];
}

- (void)setDelegate:del
{
	delegate = del;
}

@end
