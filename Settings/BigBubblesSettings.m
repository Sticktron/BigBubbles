//
//  BigBubbles Settings
//  Created by Sticktron in 2014.
//
//

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>


#define EMAIL_STICKTRON				@"mailto:sticktron@hotmail.com"
#define TWITTER_WEB_STICKTRON		@"http://twitter.com/sticktron"
#define TWITTER_APP_STICKTRON		@"twitter://user?screen_name=sticktron"
#define GITHUB_STICKTRON			@"http://github.com/Sticktron"

#define ICON_PATH					@"/Library/PreferenceBundles/BigBubblesSettings.bundle/Icon@2x.png"

#define RESPRING_TINT				[UIColor colorWithRed:0.639 green:0.412 blue:0.831 alpha:1]; /*#a369d4*/


@class BigBubblesSettingsController;
static BigBubblesSettingsController *controller = nil;





//----------------------------------------//
// Respring notification handler.
//----------------------------------------//

//static void respringNotification(CFNotificationCenterRef center, void *observer, CFStringRef name,
//								 const void *object, CFDictionaryRef userInfo) {
//	
//	if (controller) {
//		UIAlertView *alert = [[UIAlertView alloc]
//							  initWithTitle:@"Respring to enable/disable"
//							  message:@"Respring now?"
//							  delegate:controller
//							  cancelButtonTitle:@"NO"
//							  otherButtonTitles:@"YES", nil];
//		[alert show];
//	}
//}



//----------------------------------------//
// Custom cell for logo image.
//----------------------------------------//

@interface LogoCell : PSTableCell
@property (nonatomic, strong) UIImageView *logoView;
@end

@implementation LogoCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LogoCell"  specifier:specifier];
	
	if (self) {
		self.backgroundColor = [UIColor colorWithRed:1 green:45/255.0 blue:85/255.0 alpha:1];
	}
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)height {
	return 8	;
}
@end



//----------------------------------------//
// Settings controller.
//----------------------------------------//
@interface BigBubblesSettingsController : PSListController
@end


@implementation BigBubblesSettingsController

- (id)initForContentSize:(CGSize)size {
	self = [super initForContentSize:size];
	if (self) {
		controller = self;
		
//		// add a Respring button to the navbar
//		UIBarButtonItem *respringButton = [[UIBarButtonItem alloc]
//										   initWithTitle:@"Respring"
//										           style:UIBarButtonItemStyleDone
//										          target:self
//										          action:@selector(respring)];
//		
//		respringButton.tintColor = RESPRING_TINT;
//		[self.navigationItem setRightBarButtonItem:respringButton];
//		
//		
//		// register for notifications from the Enabled switch
//		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
//										NULL,
//										(CFNotificationCallback)respringNotification,
//										CFSTR("com.sticktron.bigbubbles.settings.respring"),
//										NULL,
//										CFNotificationSuspensionBehaviorDeliverImmediately);
		
	}
	
	return self;
}

- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"BigBubblesSettings" target:self];
	}
	return _specifiers;
}

- (void)setTitle:(id)title {
	[super setTitle:title];
	
	UIImage *icon = [[UIImage alloc] initWithContentsOfFile:ICON_PATH];
	if (icon) {
		UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
		self.navigationItem.titleView = iconView;
	}
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 1) {
//		[self respring];
//    }
//}

- (void)openEmailForSticktron {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:EMAIL_STICKTRON]];
}

- (void)openTwitterForSticktron {
	// try the app first, otherwise use web
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_APP_STICKTRON]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:TWITTER_WEB_STICKTRON]];
	}
}

- (void)openGitHubForSticktron {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:GITHUB_STICKTRON]];
}

@end


