//
//  SUAutomaticUpdateAlert.h
//  Sparkle
//
//  Created by Andy Matuschak on 3/18/06.
//  Copyright 2006 Andy Matuschak. All rights reserved.
//

#ifndef SUAUTOMATICUPDATEALERT_H
#define SUAUTOMATICUPDATEALERT_H

#import <WebKit/WebKit.h>
#import "SUWindowController.h"

typedef enum
{
	SUInstallNowChoice,
	SUDoNotInstallChoice
} SUAutomaticInstallationChoice;

@class SUAppcastItem, SUHost, SUReleaseNotesViewController;
@interface SUAutomaticUpdateAlert : SUWindowController
{
	SUReleaseNotesViewController *releaseNotesViewController;
	
	IBOutlet NSView *releaseNotesEnclosure;
	IBOutlet NSBox *releaseNotesBox;
	IBOutlet WebView *releaseNotesWebView;
	
	IBOutlet NSButton *autoDownloadUpdatesCheckBox;
	
	SUAppcastItem *updateItem;
	id delegate;
	SUHost *host;
	
	NSRect hiddenReleaseNotesWindowFrame;
	BOOL isShowingReleaseNotes;
}

- (id)initWithAppcastItem:(SUAppcastItem *)item host:(SUHost *)hostBundle delegate:delegate;

- (IBAction)viewReleaseNotes:(id)sender;

- (IBAction)installNow:sender;
- (IBAction)doNotInstall:sender;

- (NSString *)titleText;
- (NSString *)descriptionText;

@end

@interface NSObject (SUAutomaticUpdateAlertDelegateProtocol)
- (void)automaticUpdateAlert:(SUAutomaticUpdateAlert *)aua finishedWithChoice:(SUAutomaticInstallationChoice)choice;
@end

#endif
