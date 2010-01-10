//
//  SUReleaseNotesViewController.h
//  Sparkle
//
//  Created by Alex Gordon on 10/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class SUAppcastItem;

@interface SUReleaseNotesViewController : NSObject
{
	SUAppcastItem *updateItem;
	
	IBOutlet NSBox *webViewBox;
	IBOutlet WebView *webView;
	
	NSProgressIndicator *releaseNotesSpinner;
	BOOL webViewFinishedLoading;
}

@property (assign) SUAppcastItem *updateItem;

@property (assign) NSBox *webViewBox;
@property (assign) WebView *webView;

- (void)displayReleaseNotes;
- (void)end;

@end
