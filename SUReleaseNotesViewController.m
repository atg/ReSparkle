//
//  SUReleaseNotesViewController.m
//  Sparkle
//
//  Created by Alex Gordon on 10/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SUReleaseNotesViewController.h"
#import "SUAppcastItem.h"

@implementation SUReleaseNotesViewController

@synthesize webViewBox;
@synthesize webView;
@synthesize updateItem;

- (void)displayReleaseNotes
{
	// Set the default font	
	[webView setPreferencesIdentifier:[SPARKLE_BUNDLE bundleIdentifier]];
	[[webView preferences] setStandardFontFamily:[[NSFont systemFontOfSize:8] familyName]];
	[[webView preferences] setDefaultFontSize:(int)[NSFont systemFontSizeForControlSize:NSSmallControlSize]];
	[webView setFrameLoadDelegate:self];
	[webView setPolicyDelegate:self];
	
	// Stick a nice big spinner in the middle of the web view until the page is loaded.
	NSRect frame = [webViewBox frame];
	releaseNotesSpinner = [[[NSProgressIndicator alloc] initWithFrame:NSMakeRect(NSMidX(frame)-16, NSMidY(frame)-16, 32, 32)] autorelease];
	[releaseNotesSpinner setStyle:NSProgressIndicatorSpinningStyle];
	[releaseNotesSpinner startAnimation:self];
	webViewFinishedLoading = NO;
	[webViewBox addSubview:releaseNotesSpinner];
	
	// If there's a release notes URL, load it; otherwise, just stick the contents of the description into the web view.
	if ([updateItem releaseNotesURL])
	{
		if ([[updateItem releaseNotesURL] isFileURL])
		{
			[[webView mainFrame] loadHTMLString:@"Release notes with file:// URLs are not supported for security reasons&mdash;Javascript would be able to read files on your file system." baseURL:nil];
		}
		else
		{
			[[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[updateItem releaseNotesURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30]];
		}
	}
	else
	{
		[[webView mainFrame] loadHTMLString:[updateItem itemDescription] baseURL:nil];
	}	
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame;
{
	if ([frame parentFrame] == nil)
	{
		[releaseNotesSpinner stopAnimation:self];
		[releaseNotesSpinner setHidden:YES];
 		[sender display]; // necessary to prevent weird scroll bar artifacting
   }
}
- (void)webView:(WebView *)sender didCommitLoadForFrame:(WebFrame *)frame
{
	if ([frame parentFrame] == nil)
	{
		[releaseNotesSpinner stopAnimation:self];
		[releaseNotesSpinner setHidden:YES];
		[sender display]; // necessary to prevent weird scroll bar artifacting
    }
}
- (void)webView:(WebView *)sender didFinishLoadForFrame:frame
{
    if ([frame parentFrame] == nil)
	{
        webViewFinishedLoading = YES;
		[releaseNotesSpinner stopAnimation:self];
		[releaseNotesSpinner setHidden:YES];
		[sender display]; // necessary to prevent weird scroll bar artifacting
    }
}
- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
	if ([frame parentFrame] == nil) {
        webViewFinishedLoading = YES;
		[releaseNotesSpinner stopAnimation:self];
		[releaseNotesSpinner setHidden:YES];
    }
}

- (void)webView:sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:frame decisionListener:listener
{
    if (webViewFinishedLoading) {
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
		
        [listener ignore];
    }    
    else {
        [listener use];
    }
}

// Clean up the contextual menu.
- (NSArray *)webView:(WebView *)sender contextMenuItemsForElement:(NSDictionary *)element defaultMenuItems:(NSArray *)defaultMenuItems
{
	NSMutableArray *webViewMenuItems = [[defaultMenuItems mutableCopy] autorelease];
	
	if (webViewMenuItems)
	{
		NSEnumerator *itemEnumerator = [defaultMenuItems objectEnumerator];
		NSMenuItem *menuItem = nil;
		while ((menuItem = [itemEnumerator nextObject]))
		{
			NSInteger tag = [menuItem tag];
			
			switch (tag)
			{
				case WebMenuItemTagOpenLinkInNewWindow:
				case WebMenuItemTagDownloadLinkToDisk:
				case WebMenuItemTagOpenImageInNewWindow:
				case WebMenuItemTagDownloadImageToDisk:
				case WebMenuItemTagOpenFrameInNewWindow:
				case WebMenuItemTagGoBack:
				case WebMenuItemTagGoForward:
				case WebMenuItemTagStop:
				case WebMenuItemTagReload:		
					[webViewMenuItems removeObjectIdenticalTo: menuItem];
			}
		}
	}
	
	return webViewMenuItems;
}

- (void)end
{
	[releaseNotesSpinner stopAnimation:nil];
	[releaseNotesSpinner removeFromSuperview];
	
	[webView stopLoading:self];
	[webView setFrameLoadDelegate:nil];
	[webView setPolicyDelegate:nil];
	[webView removeFromSuperview]; // Otherwise it gets sent Esc presses (why?!) and gets very confused.
}

@end
