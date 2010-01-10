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
	NSLog(@"Sparkle update did unarchive");
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
	
	//[NSApp runModalForWindow:[alert window]]; 
	
	 	
	 //To run the release notes WebView modally we need to use modal sessions. From http://www.dejal.com/blog/2007/01/cocoa-topics-case-modal-webview
	 //Loop until some result other than continues:
	
	NSModalSession session = [NSApp beginModalSessionForWindow:[alert window]];
    
	NSRunLoop *runloop = [NSRunLoop currentRunLoop];
	
	while ([NSApp runModalSession:session] == NSRunContinuesResponse)
    {
        //Run the window modally until there are no events to process:		
		NSDate *oneHunderMS = [NSDate dateWithTimeIntervalSinceNow:0.1];
		[runloop runMode:NSDefaultRunLoopMode beforeDate:oneHunderMS];
    }
    
    [NSApp endModalSession:session];
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
