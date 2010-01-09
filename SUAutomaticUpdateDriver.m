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
	NSLog(@"Unarchiver did finish");
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
			
		case SUInstallLaterChoice:
			postponingInstallation = YES;
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
			break;

		case SUDoNotInstallChoice:
			//[host setObject:[updateItem versionString] forUserDefaultsKey:SUSkippedVersionKey];
			[self abortUpdate];
			break;
	}
}

- (BOOL)shouldInstallSynchronously
{
	//We now always install on quit so return YES
	return YES;
	
	//return postponingInstallation;
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
	//	[[alert window] setHidesOnDeactivate:NO];
		[NSApp activateIgnoringOtherApps:YES];
	}		
	
	//if ([NSApp isActive])
	//	[[alert window] makeKeyAndOrderFront:self];
	//else
	//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:NSApp];
	
	/*
	NSAlert *prompt = [[NSAlert alloc] init];
	[prompt setMessageText:[alert titleText]];
	[prompt setInformativeText:[alert descriptionText]];
	
	[prompt addButtonWithTitle:@"Install"];
	[prompt addButtonWithTitle:@"Don't Install"];
	[prompt addButtonWithTitle:@"Release Notes"];
	
	NSInteger response = [prompt runModal];
	if (response == NSAlertFirstButtonReturn)
	{
		//Install
		
		
	}
	else if (response == NSAlertSecondButtonReturn)
	{
		//Don't Install
		
		
	}
	else if (response == NSAlertSecondButtonReturn)
	{
		//Don't Install
		
		
	}
	
	*/
	[[alert window] makeKeyAndOrderFront:self];
	[NSApp runModalForWindow:[alert window]];
	
	
	//[self installUpdate];
}

- (void)installerFinishedForHost:(SUHost *)aHost
{
	//Don't relaunch as this will be triggered on quit
	return;
	
	if (aHost != host) { return; }
	if (!postponingInstallation)
		[self relaunchHostApp];
}

- (void)abortUpdateWithError:(NSError *)error
{
	if (showErrors)
		[super abortUpdateWithError:error];
	else
		[self abortUpdate];
}

@end
