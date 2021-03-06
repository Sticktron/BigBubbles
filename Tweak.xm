//
//  Big Bubbles
//	Bigger chat bubbles for image previews in the Messages App.
//  Inspired by iOS 8.
//
//  Created by Sticktron.
//  Copyright (c) 2014. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ChatKit/CKUIBehavior.h>

#define DEBUG_PREFIX @"💬 BigBubbles"
#import "DebugLog.h"


#define YES_OR_NO				@"YES":@"NO"
#define SETTINGS_PLIST_PATH		[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.sticktron.bigbubbles.plist"]

#define SIZE_BIG_PHONE			232.0f //default
#define SIZE_BIGGER_PHONE		280.0f

#define SIZE_BIG_PAD			312.0f //default
#define SIZE_BIGGER_PAD			420.0f


static BOOL is_iOS7;
static BOOL is_iPad;
static BOOL is_Enabled;
static float bubbleWidth;




//
// Helper Functions
//

// The Heavy Lifter: Calculates a new size for thumbnails using the correct aspect ratio.
static inline CGSize bigThumbSizeFromSize(CGSize size) {
	CGSize bigThumbSize = CGSizeMake(bubbleWidth, 0);
    bigThumbSize.height = (bigThumbSize.width / size.width) * size.height;
	DebugLogC(@"original thumb size:%@ || new thumb size:%@", NSStringFromCGSize(size), NSStringFromCGSize(bigThumbSize));
    return bigThumbSize;
}


// Load settings
static inline void loadSettings() {
	NSDictionary *userSettings = [NSDictionary dictionaryWithContentsOfFile:SETTINGS_PLIST_PATH];
	if (userSettings) {
		DebugLogC(@"loaded settings: %@", userSettings);
		
		if (userSettings[@"Enabled"]) {
			is_Enabled = [userSettings[@"Enabled"] boolValue];
			DebugLogC(@"found setting: Enabled = %@", is_Enabled?YES_OR_NO);
		}
		
		if (userSettings[@"BubbleWidth"]) {
			bubbleWidth = [userSettings[@"BubbleWidth"] integerValue];
			DebugLogC(@"found setting for BubbleWidth: %f", bubbleWidth);
		}
		
		/*
		if (userSettings[@"NoTails"]) {
			noTails = [userSettings[@"NoTails"] boolValue];
			DebugLogC(@"found setting for NoTails: %@",  noTails?YES_OR_NO);
		}
		
		if (userSettings[@"SquareBubbles"]) {
			squareBubbles = [userSettings[@"SquareBubbles"] boolValue];
			DebugLogC(@"found setting for SquareBubbles: %@", squareBubbles?YES_OR_NO);
		}
		*/
		
	} else {
		DebugLogC(@"no user settings.");
	}
}




//
// Hooks
//

%group iOS7
%hook CKUIBehavior
- (CGSize)thumbnailFillSizeForImageSize:(CGSize)imageSize {
	return bigThumbSizeFromSize(%orig);
}
%end
%end


%group iOS6
%hook CKUIBehavior
- (CGSize)videoPreviewBalloonImageMaxSize {
	return bigThumbSizeFromSize(%orig);
}
- (CGSize)previewBalloonImageMaxSize {
	return bigThumbSizeFromSize(%orig);
}
%end
%end




//
// Init
//

%ctor {
    @autoreleasepool {
		DebugLogC(@"initializing...");
		
		// init defaults
		is_Enabled = YES;
		is_iOS7 = (kCFCoreFoundationVersionNumber >= 847.20);
		is_iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
		
		bubbleWidth = (is_iPad) ? SIZE_BIG_PAD : SIZE_BIG_PHONE;
		
		loadSettings();
		
		if (!is_Enabled) {
			NSLog(@" BigBubbles is disabled.");
		} else {
			NSLog(@" BigBubbles is enabled.");
			
			// load hooks !
			if (is_iOS7) {
				%init(iOS7);
			} else {
				%init(iOS6);
			}
		}
	}
}

