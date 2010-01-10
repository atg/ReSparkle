//
//  SUAutomaticUpdateAlert.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/18/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "SUAutomaticUpdateAlert.h"

#import "SUHost.h"
#import "SUReleaseNotesViewController.h"

@implementation SUAutomaticUpdateAlert

- (id)initWithAppcastItem:(SUAppcastItem *)item host:(SUHost *)aHost delegate:del;
{
	self = [super initWithHost:aHost windowNibName:@"SUAutomaticUpdateAlert"];
	if (self)
	{
		updateItem = [item retain];
		delegate = del;
		host = [aHost retain];
		
		releaseNotesViewController = [[SUReleaseNotesViewController alloc] init];
		
		[self setShouldCascadeWindows:NO];	
		[[self window] center];
	}
	return self;
}

- (void)awakeFromNib
{
	releaseNotesViewController.webView = releaseNotesWebView;
	releaseNotesViewController.webViewBox = releaseNotesBox;
	releaseNotesViewController.updateItem = updateItem;
	
	//Retain these two, or they'll be prematurely deallocated when swapping them in and out
	[releaseNotesEnclosure retain];
	[releaseNotesWebView retain];
	
	hiddenReleaseNotesWindowFrame = [[self window] frame];
}

- (void)dealloc
{
	[releaseNotesEnclosure release];
	[releaseNotesWebView release];
	[releaseNotesViewController release];
	[host release];
	[updateItem release];
	[super dealloc];
}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], [host bundlePath]]; }

- (IBAction)viewReleaseNotes:(id)sender
{
	const CGFloat leftMargin = 108.0;
	const CGFloat betweenCheckboxWebViewMargin = 12.0;
	const CGFloat rightMargin = 20.0;
	
	CGFloat increase = [releaseNotesEnclosure frame].size.height + betweenCheckboxWebViewMargin;
	if (isShowingReleaseNotes)
	{
		//Hide the release notes
		NSRect newWindowRect = hiddenReleaseNotesWindowFrame;
		newWindowRect.origin.y = [[self window] frame].origin.y + increase;
		newWindowRect.origin.x = [[self window] frame].origin.x;
		[releaseNotesEnclosure removeFromSuperview];
		[[self window] setFrame:newWindowRect display:YES animate:YES];
		
		[releaseNotesViewController end];
	}
	else
	{
		//Show the release notes
		
		NSRect newWindowRect = hiddenReleaseNotesWindowFrame;
		newWindowRect.size.height += increase;
		newWindowRect.origin.y = [[self window] frame].origin.y - increase;
		newWindowRect.origin.x = [[self window] frame].origin.x;
		[[self window] setFrame:newWindowRect display:YES animate:YES];
		
		NSRect newWebRect = [releaseNotesEnclosure frame];
		newWebRect.origin.x = leftMargin;
		newWebRect.origin.y = NSMaxY([autoDownloadUpdatesCheckBox frame]) + betweenCheckboxWebViewMargin;
		newWebRect.size.width = newWindowRect.size.width - newWebRect.origin.x - rightMargin;
		
		[releaseNotesEnclosure setFrame:newWebRect];
		[[[self window] contentView] addSubview:releaseNotesEnclosure
									 positioned:NSWindowBelow
									 relativeTo:[[[[self window] contentView] subviews] objectAtIndex:0]];
		
		if (![[releaseNotesBox subviews] containsObject:releaseNotesWebView])
			[releaseNotesBox addSubview:releaseNotesWebView];
		[releaseNotesViewController displayReleaseNotes];
	}
	
	isShowingReleaseNotes = !isShowingReleaseNotes;
}

- (IBAction)installNow:sender
{
	[delegate automaticUpdateAlert:self finishedWithChoice:SUInstallNowChoice];
	[self close];
}

- (IBAction)doNotInstall:sender
{
	[delegate automaticUpdateAlert:self finishedWithChoice:SUDoNotInstallChoice];
	[self close];
}

- (void)close
{
	[releaseNotesViewController end];
	[super close];
}

- (NSImage *)applicationIcon
{
	return [host icon];
}

- (NSString *)titleText
{
	return [NSString stringWithFormat:SULocalizedString(@"A new version of %@ is ready to install!", nil), [host name]];
}

- (NSString *)descriptionText
{
	//New ReSparkle text
	return [NSString stringWithFormat:SULocalizedString(@"%1$@ %2$@ has been downloaded and is ready to install. Would you like to install it now? %1$@ will not be relaunched.", nil), [host name], [updateItem displayVersionString]];
	
	//Old Sparkle text
	//return [NSString stringWithFormat:SULocalizedString(@"%1$@ %2$@ has been downloaded and is ready to use! Would you like to install it and relaunch %1$@ now?", nil), [host name], [updateItem displayVersionString]];
}

@end
