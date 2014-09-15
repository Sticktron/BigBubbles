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

#define VERSION_STRING			@"BigBubbles v1.0.6"




//
// Interfaces
//

@interface BigBubblesSettingsController : PSListController
@property (nonatomic, strong) UIAlertView *hud;
@property (nonatomic, strong) PSSpecifier *slider;
@property (nonatomic, strong) PSSpecifier *sizeList;
@end

@interface MGBBStripeCell : PSTableCell
@end

@interface MGBBPreviewCell : PSTableCell
@property (nonatomic, strong) UIImageView *previewBubble;
- (void)scaleBubble:(float)value;
- (void)syncBubbleSize;
@end




//
// Globals
//

#define YES_OR_NO				@"YES":@"NO"
#define is_iPad					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define PINK					[UIColor colorWithRed:1 green:45/255.0 blue:85/255.0 alpha:1]
#define PURPLE					[UIColor colorWithRed:128/255.0 green:0 blue:1 alpha:1]
#define URL_EMAIL				@"mailto:sticktron@hotmail.com"
#define URL_TWITTER_APP			@"twitter://user?screen_name=sticktron"
#define URL_TWITTER_WEB			@"http://twitter.com/sticktron"
#define URL_GITHUB				@"http://github.com/Sticktron/BigBubbles"
#define URL_REDDIT				@"http://reddit.com/r/jailbreak"
#define URL_WEBSITE				@"http://sticktron.com"
#define URL_PAYPAL				@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=BKGYMJNGXM424&lc=CA&item_name=Donation%20to%20Sticktron&item_number=BigBubbles&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted"

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

static BigBubblesSettingsController *controller;



//
// Settings Controller
//

@implementation BigBubblesSettingsController
- (id)initForContentSize:(CGSize)size {
	DebugLog0;
	
	self = [super initForContentSize:size];
	if (self) {
		_slider = [self specifierForID:@"BubbleSizeSlider"];
		_sizeList = [self specifierForID:@"BubbleSizeList"];
		DebugLog(@"self.slider = %@", _slider);
		DebugLog(@"self.sizeList = %@", _sizeList);
		
		// configure the slider
		if (_slider) {
			[_slider setProperty:[NSNumber numberWithFloat:[self sizeForSize:@"min"]] forKey:@"min"];
			[_slider setProperty:[NSNumber numberWithFloat:[self sizeForSize:@"max"]] forKey:@"max"];
			[_slider setProperty:[NSNumber numberWithFloat:[self sizeForSize:@"default"]] forKey:@"default"];
			[self showOrHideSlider];
		}
		
		// create the loading alert
		_hud = [[UIAlertView alloc] initWithTitle:@"Applyling Changes..."
										  message:nil
										 delegate:nil
								cancelButtonTitle:nil
								otherButtonTitles:nil];
	}
	controller = self;
	return self;
}
- (id)specifiers {
	DebugLog0;
	
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"BigBubblesSettings" target:self];
	}
	return _specifiers;
}
- (void)setTitle:(id)title {
	[super setTitle:title];
	
	UIImage *icon = [[UIImage alloc] initWithContentsOfFile:SETTINGS_ICON_PATH];
	if (icon) {
		UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
		self.navigationItem.titleView = iconView;
	}
}
- (float)sizeForSize:(NSString *)size {
	DebugLog(@"arg 'size' = %@", size);
	
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
- (void)showOrHideSlider {
	NSString *setting = [self readPreferenceValue:self.sizeList];
	DebugLog(@"got pref from SizeList: 'BubbleSize'=%@", setting);
	
	if (setting && [setting isEqualToString:@"custom"]) {
		DebugLog(@"should show");
		[self insertSpecifier:self.slider afterSpecifier:self.sizeList];
		
		MGBBPreviewCell *previewCell = [[self specifierForID:@"SizeGroupCell"] propertyForKey:@"footerView"];
		if (previewCell) {
			[previewCell syncBubbleSize];
		}
	} else {
		DebugLog(@"should hide");
		[self removeSpecifier:self.slider animated:NO];
	}
}
- (void)setEnabledSwitch:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"set %@=%@", [specifier propertyForKey:@"key"], value);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self applyChanges];
}
- (void)setSizeListValue:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"set value:%@ for key:%@ for specifier named:%@", value, [specifier propertyForKey:@"key"], specifier.name);
	
	[self setPreferenceValue:value specifier:specifier];
	
	if (![value isEqualToString:@"custom"]) {
		// chose Big or Bigger, mode the slider manually
		NSNumber *sliderValue = [NSNumber numberWithFloat:[self sizeForSize:value]];
		DebugLog(@"setting slider value to: %@", sliderValue);
		[self setSliderValue:sliderValue specifier:self.slider];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self reloadSpecifiers];
	[self showOrHideSlider];
}
- (void)setSliderValue:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog0;
	
	DebugLog(@"setting pref '%@' to: %f", [specifier propertyForKey:@"key"], [value floatValue]);
	[self setPreferenceValue:value specifier:specifier];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
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




//
// Header Stripe Cell
//

@implementation MGBBStripeCell
- (id)initWithSpecifier:(id)specifier {
	DebugLog0;
	
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"MGBBStripeCell"
					  specifier:specifier];
	
	if (self) {
		DebugLog(@"MGBBStripeCell = %@", self);
		self.backgroundColor = PINK;
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, self.bounds.size.width, 23.0)];
		label.textColor = UIColor.whiteColor;
		label.text = VERSION_STRING;
		label.textAlignment = NSTextAlignmentCenter;
		
		UIFont *customFont = [UIFont fontWithName:@"AvenirNextCondensed-DemiBold" size:11.0];
		if (customFont) {
			label.font = customFont;
		} else {
			label.font = [UIFont systemFontOfSize:11.0];
		}
		
		[self addSubview:label];
	}
	
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)height {
	return 24.0f;
}
@end




//
// Preview Cell
//

@implementation MGBBPreviewCell
- (id)initWithSpecifier:(id)specifier {
	DebugLog0;
	
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:@"MGBBPreviewCell"
					  specifier:specifier];
	
	if (self) {
		self.backgroundColor = UIColor.clearColor;
		
		// preview bg image ...
		
		UIImage *bgImage = [[UIImage alloc] initWithContentsOfFile:PHONE_IMAGE_PATH];
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:bgImage];
		
		CGRect frame = bgImageView.frame;
		frame.origin.x = (self.bounds.size.width - bgImageView.frame.size.width) / 2.0;
		frame.origin.y = 30.0;
		bgImageView.frame = frame;
		
		
		// preview bubble image ...
		
		UIImage *bubbleImage = [[UIImage alloc] initWithContentsOfFile:BUBBLE_IMAGE_PATH];
		_previewBubble = [[UIImageView alloc] initWithImage:bubbleImage];
		
		frame = _previewBubble.frame;
		frame.origin.x = ORIGIN_PREVIEW_X - frame.size.width;
		frame.origin.y = ORIGIN_PREVIEW_Y - frame.size.height;
		_previewBubble.frame = frame;
		
		[bgImageView addSubview:_previewBubble];
		[self addSubview:bgImageView];
		
		[self syncBubbleSize];
	}
	
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)height {
	return 330.0f;
}
- (void)scaleBubble:(float)size {
	DebugLog(@"size: %f", size);
	
	if (self.previewBubble) {
		DebugLog(@"preview bubble exists");
		
		CGRect pframe = self.previewBubble.frame;
		DebugLog(@"> current frame = %@", NSStringFromCGRect(pframe));
		
		if (!CGRectIsEmpty(pframe)) {
			
			// calc new width ...
			
			float max = (is_iPad) ? SIZE_MAX_PAD : SIZE_MAX_PHONE;
			float oldWidth = pframe.size.width;
			
			float diff = (size - SIZE_MIN) * (SIZE_PREVIEW_MAX - SIZE_PREVIEW_MIN);
			float range = (max - SIZE_MIN);
			float newWidth = (diff/range) + SIZE_PREVIEW_MIN;
			
			pframe.size.width = newWidth;
			
			
			// calc new height
			pframe.size.height = (newWidth / oldWidth) * pframe.size.height;
			
			
			// fix origin
			pframe.origin.x = ORIGIN_PREVIEW_X - pframe.size.width;
			pframe.origin.y = ORIGIN_PREVIEW_Y - pframe.size.height;
			
			
			DebugLog(@"> setting frame to: %@", NSStringFromCGRect(pframe));
			self.previewBubble.frame = pframe;
		}
	}
}
- (void)syncBubbleSize {
	DebugLog0;
	
	DebugLog(@"controller exists? %@", controller?YES_OR_NO);
	
	if (controller && controller.slider) {
		DebugLog(@"slider exists? %@", controller.slider?YES_OR_NO);
		
		id setting = [controller readPreferenceValue:controller.slider];
		DebugLog(@"setting=%@", setting);
		
		
		float size = [setting floatValue];
		DebugLog(@"size=%f", size);
		
		if (size) {
			DebugLog(@"adjusting preview to: %f...", size);
			[self scaleBubble:size];
		} else {
			DebugLog(@"no size fail");
		}
	}
}
@end




//
// Slider Cell
//
@interface MGBBSliderCell : PSSliderTableCell
@end

@implementation MGBBSliderCell
- (id)initWithStyle:(long long)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
	DebugLog0;
	
	//reuseIdentifier:@"MGBBSliderCell"
	self = [super initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:reuseIdentifier
					  specifier:specifier];
	
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

