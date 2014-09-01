//
//  Big Bubbles - Settings
//
//  Created by Sticktron.
//  Copyright (c) 2014. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "theos/include/UIKit/UIProgressHUD.h"
#import <Preferences/PSListController.h>
#import <Preferences/PSSliderTableCell.h>
#import <Preferences/PSSpecifier.h>

#define DEBUG_PREFIX			@"BigBubbles-Settings[debug]"
#import "../DebugLog.h"


#define YES_OR_NO				@"YES":@"NO"

#define PINK					[UIColor colorWithRed:1 green:45/255.0 blue:85/255.0 alpha:1]
#define PURPLE					[UIColor colorWithRed:128/255.0 green:0 blue:1 alpha:1]

#define URL_EMAIL				@"mailto:sticktron@hotmail.com"
#define URL_TWITTER_APP			@"twitter://user?screen_name=sticktron"
#define URL_TWITTER_WEB			@"http://twitter.com/sticktron"
#define URL_GITHUB				@"http://github.com/Sticktron/BigBubbles"
#define URL_REDDIT				@"http://reddit.com/r/jailbreak"
#define URL_WEBSITE				@"http://sticktron.com"
#define URL_PAYPAL				@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=BKGYMJNGXM424&lc=CA&item_name=Donation%20to%20Sticktron&item_number=BigBubbles&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"

#define SETTINGS_PLIST_PATH		[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/com.sticktron.bigbubbles.plist"]
#define SETTINGS_ICON_PATH		@"/Library/PreferenceBundles/BigBubblesSettings.bundle/Icon@2x.png"
#define PHONE_IMAGE_PATH		@"/Library/PreferenceBundles/BigBubblesSettings.bundle/preview-phone@2x.png"
#define BUBBLE_IMAGE_PATH		@"/Library/PreferenceBundles/BigBubblesSettings.bundle/preview-bubble@2x.png"

#define SIZE_MIN				64.0

#define SIZE_BIG_PHONE			232.0
#define SIZE_BIGGER_PHONE		280.0
#define SIZE_MAX_PHONE			300.0

#define SIZE_BIG_PAD			312.0
#define SIZE_BIGGER_PAD			420.0
#define SIZE_MAX_PAD			512.0

#define SIZE_PREVIEW_MIN		26.0
#define SIZE_PREVIEW_MAX		101.0

#define ORIGIN_PREVIEW_X		116.0
#define ORIGIN_PREVIEW_Y		209.0


#define is_iPad					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


//
// Header Stripe Cell
//
@interface MGBBStripeCell : PSTableCell
@end

@implementation MGBBStripeCell
- (id)initWithSpecifier:(id)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"MGBBStripeCell"
					  specifier:specifier];
	
	if (self) {
		self.backgroundColor = PINK;
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 2.0, self.bounds.size.width, 24.0)];
		label.textColor = UIColor.whiteColor;
		label.font = [UIFont fontWithName:@"DINCondensed-Bold" size:12.0];
		label.text = @"BigBubbles v1.0.5";
		label.textAlignment = NSTextAlignmentCenter;
		
		[self addSubview:label];
	}
	
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)height {
	return 24.0;
}
@end


//
// Preview Cell
//
@interface MGBBPreviewCell : PSTableCell
@property (nonatomic, strong) UIImageView *previewBubble;
@end

@implementation MGBBPreviewCell
- (id)initWithSpecifier:(id)specifier {
	DebugLog0;
	
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"MGBBPreviewCell"
					  specifier:specifier];
	
	if (self) {
		self.backgroundColor = UIColor.clearColor;
		
		// create preview imageview ...
		
		UIImage *bgImage = [[UIImage alloc] initWithContentsOfFile:PHONE_IMAGE_PATH];
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
		
		CGRect frame = bgImageView.frame;
		frame.origin.x = (self.bounds.size.width - bgImageView.frame.size.width) / 2.0;
		frame.origin.y = 30.0;
		bgImageView.frame = frame;
		
		
		// create preview bubble view ...
		
		UIImage *bubbleImage = [[UIImage alloc] initWithContentsOfFile:BUBBLE_IMAGE_PATH];
		_previewBubble = [[UIImageView alloc] initWithImage:bubbleImage];
		
		frame = _previewBubble.frame;
		frame.origin.x = ORIGIN_PREVIEW_X - frame.size.width;
		frame.origin.y = ORIGIN_PREVIEW_Y - frame.size.height;
		_previewBubble.frame = frame;
		
		
		// add views
		[bgImageView addSubview:_previewBubble];
		[self addSubview:bgImageView];
	}
	
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)height {
	return 330.0;
}
- (void)scaleBubble:(float)value {
	CGRect frame = self.previewBubble.frame;
	float max = (is_iPad) ? SIZE_MAX_PAD : SIZE_MAX_PHONE;
	float oldWidth = frame.size.width;
	float newWidth = (((value - SIZE_MIN) * (SIZE_PREVIEW_MAX - SIZE_PREVIEW_MIN)) / (max - SIZE_MIN)) + SIZE_PREVIEW_MIN;
	frame.size.width = newWidth;
	frame.size.height = (newWidth / oldWidth) * frame.size.height;
	
	frame.origin.x = ORIGIN_PREVIEW_X - frame.size.width;
	frame.origin.y = ORIGIN_PREVIEW_Y - frame.size.height;
	self.previewBubble.frame = frame;
}
@end


//
// Slider Cell
//
@interface MGBBSliderCell : PSSliderTableCell
@end

@implementation MGBBSliderCell
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 {
	DebugLog0;
	
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"MGBBSliderCell"
					  specifier:arg3];
	
	if (self) {
		UISlider *slider = (UISlider *)self.control;
		slider.minimumTrackTintColor = PINK;
		slider.maximumTrackTintColor = PURPLE;
		
		// UIControlEventValueChanged isn't firing continuously, so I'm using TouchDragInside instead
		[slider addTarget:self.specifier.target action:@selector(sliderMoved:) forControlEvents:UIControlEventTouchDragInside];
	}
	return self;
}
@end





//
// Settings Controller
//
@interface BigBubblesSettingsController : PSListController
@property (nonatomic, strong) UIAlertView *hud;
@property (nonatomic, strong) PSSpecifier *slider;
@property (nonatomic, strong) PSSpecifier *sizeList;
@end

@implementation BigBubblesSettingsController

- (id)initForContentSize:(CGSize)size {
	DebugLog0;
	
	self = [super initForContentSize:size];
	if (self) {
		_hud = [[UIAlertView alloc] initWithTitle:@"Applyling Changes..."
										  message:nil
										 delegate:nil
							   cancelButtonTitle:nil
							   otherButtonTitles:nil];
	}
	return self;
}

- (id)specifiers {
	DebugLog0;
	
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"BigBubblesSettings" target:self];
		
		self.slider = [self specifierForID:@"BubbleSizeSlider"];
		self.sizeList = [self specifierForID:@"BubbleSizeList"];
		
		// set the slider range and default value
		[self.slider setProperty:[NSNumber numberWithFloat:[self sizeForSize:@"min"]] forKey:@"min"];
		[self.slider setProperty:[NSNumber numberWithFloat:[self sizeForSize:@"max"]] forKey:@"max"];
		[self.slider setProperty:[NSNumber numberWithFloat:[self sizeForSize:@"default"]] forKey:@"default"];
		
		[[self.slider propertyForKey:@"control"] setEnabled:NO];
	}
	
	return _specifiers;
}




//- (void)viewWillAppear:(BOOL)animated {
//	DebugLog0;
//	[super viewWillAppear:animated];
- (void)viewDidLayoutSubviews {
	DebugLog0;
	[super viewDidLayoutSubviews];
	
	// set the enabled state of slider
	NSString *bubbleSize = [self readPreferenceValue:self.sizeList];
	DebugLog(@"prefs[BubbleSize]: %@", bubbleSize);
	[self showSlider:([bubbleSize isEqualToString:@"custom"])];
	
	// sync the preview size to the slider value
	MGBBPreviewCell *previewCell = [[self specifierForID:@"SizeGroupCell"] propertyForKey:@"footerView"];
	float size = [[self readPreferenceValue:self.slider] floatValue];
	DebugLog(@"adjusting preview to: %f...", size);
	[previewCell scaleBubble:size];
}






- (void)setTitle:(id)title {
	[super setTitle:title];
	
	UIImage *icon = [[UIImage alloc] initWithContentsOfFile:SETTINGS_ICON_PATH];
	if (icon) {
		UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
		self.navigationItem.titleView = iconView;
	}
}

//

- (float)sizeForSize:(NSString *)size {
	float result = 0;

	if ([size isEqualToString:@"min"]) {
		result = SIZE_MIN;
		
	} else if ([size isEqualToString:@"max"]) {
		result = is_iPad ? SIZE_MAX_PAD : SIZE_MAX_PHONE;
		
	} else if([size isEqualToString:@"big"]) {
		result = is_iPad ? SIZE_BIG_PAD : SIZE_BIG_PHONE;
		
	} else if ([size isEqualToString:@"default"] || [size isEqualToString:@"bigger"]) {
		result = is_iPad ? SIZE_BIGGER_PAD : SIZE_BIGGER_PHONE;
	}
	
	return result;
}

- (void)sliderMoved:(UISlider *)slider {
	DebugLog(@"slider.value=%f", slider.value);
	
	MGBBPreviewCell *previewCell = [[self specifierForID:@"SizeGroupCell"] propertyForKey:@"footerView"];
	[previewCell scaleBubble:slider.value];
}

- (void)showSlider:(BOOL)shouldShow {
	DebugLog0;
	
	DebugLog(@"prefs[BubbleSize]: %@", [self readPreferenceValue:self.sizeList]);
	
	UISlider *control = [self.slider propertyForKey:@"control"];
	DebugLog(@"control: %@", control);
	
	control.enabled = shouldShow;
}

- (void)setEnabledSwitch:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"set %@=%@", [specifier propertyForKey:@"key"], value);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self applyChanges];
}

/*
- (void)setNoTailsSwitch:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"set %@=%@", [specifier propertyForKey:@"key"], value);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//
	// TODO: update preview image here
	//
}

- (void)setSquareBubblesSwitch:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"set %@=%@", [specifier propertyForKey:@"key"], value);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//
	// TODO: update preview image here
	//
}
*/

- (void)setSizeListValue:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"set value:%@ for key:%@ for specifier named:%@", value, [specifier propertyForKey:@"key"], specifier.name);
	
	[self setPreferenceValue:value specifier:specifier];
	
	if ([value isEqualToString:@"custom"]) {
		// chose Custom, show slider
		[self showSlider:YES];
	} else {
		// chose Big or Bigger...
		
		// set slider value manually
		NSNumber *sliderValue = [NSNumber numberWithFloat:[self sizeForSize:value]];
		DebugLog(@"setting slider value to: %@", sliderValue);
		[self setSliderValue:sliderValue specifier:self.slider];
		
		// hide slider
		[self showSlider:NO];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self reloadSpecifiers];
}

- (void)setSliderValue:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog0;
	
	DebugLog(@"setting pref '%@' to: %f", [specifier propertyForKey:@"key"], [value floatValue]);
	[self setPreferenceValue:value specifier:specifier];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applyChanges {
	DebugLog(@"Applying Setings...");
	
	// show alert
	[self.hud show];
	
	
	//
	// Step 1.
	DebugLog(@">> quitting Messages");
	system("killall MobileSMS");
	
	
	//
	// Step 2.
	DebugLog(@">> deleting cached thumbnails");
	
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/SMS/Attachments/"];
	DebugLog(@"using path:%@", path);
	
	NSDirectoryEnumerator *filesEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
	
	int count = 0;
	NSString *file;
	NSError *error;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"preview"
																		   options:NSRegularExpressionCaseInsensitive
																			 error:nil];
	
	while (file = [filesEnumerator nextObject]) {
		NSUInteger match = [regex numberOfMatchesInString:file options:0 range:NSMakeRange(0, [file length])];
		
		if (match) {
			DebugLog(@"deleting file: '%@'", file);
			[[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:file] error:&error];
			count++;
		}
	}
	DebugLog(@"deleted %d files", count);
	
	
	// dismiss alert
	[self.hud dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)openEmail {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_EMAIL]];
}

- (void)openTwitter {
	// try the app first, otherwise use web
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_TWITTER_APP]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_TWITTER_WEB]];
	}
}

- (void)openGitHub {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_GITHUB]];
}

- (void)openReddit {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_REDDIT]];
}

- (void)openWebsite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_WEBSITE]];
}

- (void)openPayPal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_PAYPAL]];
}

@end

