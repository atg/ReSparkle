//
//  SUAutomaticUpdateDriver.m
//  Sparkle
//
//  Created by Andy Matuschak on 5/6/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#import "SUAutomaticUpdateDriver.h"

#import "SUAutomaticUpdateAlert.h"
#import "SUHost.h"

@implementation SUAutomaticUpdateDriver

- (void)unarchiverDidFinish:(SUUnarchiver *)ua
{
	alert = [[SUAutomaticUpdateAlert alloc] initWithAppcastItem:updateItem host:host delegate:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	[[alert window] makeKeyAndOrderFront:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"NSApplicationDidBecomeActiveNotification" object:NSApp];
}

- (void)automaticUpdateAlert:(SUAutomaticUpdateAlert *)aua finishedWithChoice:(SUAutomaticInstallationChoice)choice;
{
	[NSApp stopModal];
	
	switch (choice)
	{
		case SUInstallNowChoice:
			[self installUpdate];
			break;
		
		case SUDoNotInstallChoice:
			[self abortUpdate];
			break;
	}
}

- (BOOL)shouldInstallSynchronously
{
	//We now only install on quit so return YES
	return YES;
}

- (void)installUpdate
{	
	showErrors = YES;
	[super installUpdate];
}

- (void)applicationWillTerminate:(NSNotification *)note
{
	// If the app is a menubar app or the like, we need to focus it first and alter the
	// update prompt to behave like a normal window. Otherwise if the window were hidden
	// there may be no way for the application to be activated to make it visible again.
	
	if ([host isBackgroundApplication])
	{
		[NSApp activateIgnoringOtherApps:YES];
	}		
	
	[[alert window] makeKeyAndOrderFront:self];
	[NSApp runModalForWindow:[alert window]];
}

- (void)installerFinishedForHost:(SUHost *)aHost
{
	//Don't relaunch as this will be triggered on quit
	return;
}

- (void)abortUpdateWithError:(NSError *)error
{
	if (showErrors)
		[super abortUpdateWithError:error];
	else
		[self abortUpdate];
}

@end
