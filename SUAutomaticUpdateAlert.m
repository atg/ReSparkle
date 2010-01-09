//
//  SUAutomaticUpdateAlert.m
//  Sparkle
//
//  Created by Andy Matuschak on 3/18/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#import "SUAutomaticUpdateAlert.h"

#import "SUHost.h"

@implementation SUAutomaticUpdateAlert

- (id)initWithAppcastItem:(SUAppcastItem *)item host:(SUHost *)aHost delegate:del;
{
	self = [super initWithHost:aHost windowNibName:@"SUAutomaticUpdateAlert"];
	if (self)
	{
		updateItem = [item retain];
		delegate = del;
		host = [aHost retain];
		[self setShouldCascadeWindows:NO];	
		[[self window] center];
	}
	return self;
}

- (void)dealloc
{
	[host release];
	[updateItem release];
	[super dealloc];
}

- (NSString *)description { return [NSString stringWithFormat:@"%@ <%@>", [self class], [host bundlePath]]; }

- (IBAction)viewReleaseNotes:(id)sender
{
	//FIXME: Show release notes
}

- (IBAction)installNow:sender
{
	[delegate automaticUpdateAlert:self finishedWithChoice:SUInstallNowChoice];
	[self close];
}

- (IBAction)installLater:sender
{
	[delegate automaticUpdateAlert:self finishedWithChoice:SUInstallLaterChoice];
	[self close];
}

- (IBAction)doNotInstall:sender
{
	[delegate automaticUpdateAlert:self finishedWithChoice:SUDoNotInstallChoice];
	[self close];
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
	return [NSString stringWithFormat:SULocalizedString(@"%1$@ %2$@ has been downloaded and is ready to use! Would you like to install it and relaunch %1$@ now?", nil), [host name], [updateItem displayVersionString]];
	
	//Old Sparkle text
	//return [NSString stringWithFormat:SULocalizedString(@"%1$@ %2$@ has been downloaded and is ready to use! Would you like to install it and relaunch %1$@ now?", nil), [host name], [updateItem displayVersionString]];
}

@end
