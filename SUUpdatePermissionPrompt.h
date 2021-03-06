//
//  SUUpdatePermissionPrompt.h
//  Sparkle
//
//  Created by Andy Matuschak on 1/24/08.
//  Copyright 2008 Andy Matuschak. All rights reserved.
//

#ifndef SUUPDATEPERMISSIONPROMPT_H
#define SUUPDATEPERMISSIONPROMPT_H

#import "SUWindowController.h"

typedef enum {
	SUAutomaticallyCheck,
	SUDoNotAutomaticallyCheck
} SUPermissionPromptResult;

typedef enum {
	SUAutomaticallyDownload,
	SUDoNotAutomaticallyDownload
} SUDownloadPermissionPromptResult;

@class SUHost;
@interface SUUpdatePermissionPrompt : SUWindowController {
	SUHost *host;
	NSArray *systemProfileInformationArray;
	id delegate;
	IBOutlet NSTextField *descriptionTextField;
	IBOutlet NSView *moreInfoView;
	IBOutlet NSButton *moreInfoButton;
	BOOL isShowingMoreInfo, shouldSendProfile;
}
+ (void)promptWithHost:(SUHost *)aHost systemProfile:(NSArray *)profile delegate:(id)d;
- (IBAction)toggleMoreInfo:(id)sender;
- (IBAction)finishPrompt:(id)sender;
@end

@interface NSObject (SUUpdatePermissionPromptDelegateInformalProtocol)

//Unused in ReSparkle
- (void)updatePermissionPromptFinishedWithResult:(SUPermissionPromptResult)result;

//ReSparkle only
- (void)downloadPermissionPromptFinishedWithResult:(SUDownloadPermissionPromptResult)result;

@end

#endif
