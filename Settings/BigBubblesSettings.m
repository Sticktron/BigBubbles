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
#import <Preferences/PSTableCell.h>

#define DEBUG_PREFIX			@"💬  BigBubbles_Settings >>"
#import "../DebugLog.h"


#ifdef DEBUG
	#define VERSION_STRING		@"BigBubbles  •  1.0.6_debug"
#else
	#define VERSION_STRING		@"BigBubbles  •  1.0.6"
#endif

#define YES_OR_NO				@"YES":@"NO"
#define is_iPad					(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define PINK					[UIColor colorWithRed:1 green:45/255.0 blue:85/255.0 alpha:1]
#define PURPLE					[UIColor colorWithRed:128/255.0 green:0 blue:1 alpha:1]

#define CUSTOM_FONT				@"AvenirNextCondensed-DemiBold"

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

@class MGBBPreviewCell;



// Interfaces ------------------------------------------------------------------

@interface BigBubblesSettingsController : PSListController
@property (nonatomic, strong) UIAlertView *hud;
@property (nonatomic, strong) PSSpecifier *sizeListSpec;
@property (nonatomic, strong) PSSpecifier *sliderSpec;
@property (nonatomic, strong) MGBBPreviewCell *previewCell;
@end

//------------------------------------------------------------------------------

@interface MGBBStripeCell : PSTableCell
@end

//------------------------------------------------------------------------------

@interface MGBBSliderCell : PSSliderTableCell
- (void)disableSliderIfNecessary;
@end

//------------------------------------------------------------------------------

@interface MGBBPreviewCell : PSTableCell
@property (nonatomic, strong) UIImageView *previewBubble;
- (void)scaleBubble:(float)value;
- (void)syncBubbleSize;
@end





static BigBubblesSettingsController *bbcontroller;
static UIImage *titleIcon;
static UIImage *previewBubbleImage;
static UIImage *previewPhoneImage;





// Settings Controller ---------------------------------------------------------

@implementation BigBubblesSettingsController
- (instancetype)initForContentSize:(CGSize)size {
	self = [super initForContentSize:size];
	if (self) {
		bbcontroller = self;
		
		self.sizeListSpec = [self specifierForID:@"BubbleSizeList"];
		self.sliderSpec = [self specifierForID:@"BubbleSizeSlider"];
		
		// create the loading alert
		_hud = [[UIAlertView alloc] initWithTitle:@"Applyling Changes..."
										  message:nil
										 delegate:nil
								cancelButtonTitle:nil
								otherButtonTitles:nil];
	}
	return self;
}
- (id)specifiers {
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"BigBubblesSettings" target:self];
		DebugLog(@"loaded specifiers: %@", _specifiers);
	}
	return _specifiers;
}
- (void)setTitle:(id)title {
	if (!titleIcon) {
		titleIcon = [[UIImage alloc] initWithContentsOfFile:SETTINGS_ICON_PATH];
		if (!titleIcon) {
			DebugLog(@"title icon missing");
		}
	}
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:titleIcon];
}
- (void)viewDidLoad {
	// add a heart button to the navbar
	UIBarButtonItem *heartButton = [[UIBarButtonItem alloc]
									initWithTitle:@"Love"
									style:UIBarButtonItemStyleDone
									target:self
									action:@selector(showLove)];
	
	heartButton.tintColor = PINK;
	[self.navigationItem setRightBarButtonItem:heartButton];
}
//
- (void)setEnabledSwitch:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog(@"set %@=%@", [specifier propertyForKey:@"key"], value);
	
	[self setPreferenceValue:value specifier:specifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self applyChanges];
}
- (void)setSizeListValue:(id)value specifier:(PSSpecifier *)specifier {
	DebugLog0;
	
	[self setPreferenceValue:value specifier:specifier];
	
	// if Big or Bigger was chosen adjust the slider value programmatically
	if (![value isEqualToString:@"custom"]) {
		NSNumber *sliderValue = [NSNumber numberWithFloat:[self sizeForSize:value]];
		DebugLog(@"moving slider to: %@", sliderValue);
		
		[self setPreferenceValue:sliderValue specifier:self.sliderSpec];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[bbcontroller reloadSpecifiers];
}
- (void)sliderMoved:(UISlider *)slider {
	DebugLog(@"new value (%f) for preview cell (%@)", slider.value, self.previewCell);
	[self.previewCell scaleBubble:slider.value];
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
	
	DebugLog(@"returning: %f for size (%@)", result, size);
	return result;
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
//
- (void)openEmail {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_EMAIL]];
}
- (void)openTwitter {
	NSString *user = @"sticktron";
	
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
		
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
		
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
		
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
		
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
	}
}
- (void)openReddit {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_REDDIT]];
}
- (void)openPayPal {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL_PAYPAL]];
}
- (void)showLove {
	DebugLog(@"much love");
	
	// prepare a Tweet here...
	//
	// TODO
	//
	//
	
}
@end



// Stripe Cell -----------------------------------------------------------------

@implementation MGBBStripeCell
- (id)initWithSpecifier:(id)specifier {
	static NSString *cellID = @"myMGBBStripeCell";
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID specifier:specifier];
	
	if (self) {
		DebugLog0;
		
		self.backgroundColor = PINK;
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, self.bounds.size.width, [self preferredHeightForWidth:0] - 1)];
		label.textColor = UIColor.whiteColor;
		label.text = VERSION_STRING;
		label.textAlignment = NSTextAlignmentCenter;
		
		// make sure the font exists !!!
		UIFont *customFont = [UIFont fontWithName:CUSTOM_FONT size:11.0];
		if (customFont) {
			label.font = customFont;
		} else {
			label.font = [UIFont systemFontOfSize:11.0];
		}
		
		[self addSubview:label];
	}
	
	return self;
}
- (CGFloat)preferredHeightForWidth:(CGFloat)width {
	return 24.0f;
}
@end



// Preview Cell ----------------------------------------------------------------

@implementation MGBBPreviewCell
- (id)initWithSpecifier:(id)specifier {
	
	static NSString *cellID = @"myMGBBPreviewCell";
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID specifier:specifier];
	if (self) {
		self.backgroundColor = UIColor.clearColor;
		
		// make preview bg imageview...
		
		if (!previewPhoneImage) {
			previewPhoneImage = [[UIImage alloc] initWithContentsOfFile:PHONE_IMAGE_PATH];
		}
		
		UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:previewPhoneImage];
		CGRect aframe = phoneImageView.frame;
		aframe.origin.x = (self.bounds.size.width - phoneImageView.frame.size.width) / 2.0;
		aframe.origin.y = 30.0;
		phoneImageView.frame = aframe;
		
		
		// make preview bubble imageview ...
		
		if (!previewBubbleImage) {
			previewBubbleImage = [[UIImage alloc] initWithContentsOfFile:BUBBLE_IMAGE_PATH];
		}
		
		_previewBubble = [[UIImageView alloc] initWithImage:previewBubbleImage];
		aframe = _previewBubble.frame;
		aframe.origin.x = ORIGIN_PREVIEW_X - aframe.size.width;
		aframe.origin.y = ORIGIN_PREVIEW_Y - aframe.size.height;
		_previewBubble.frame = aframe;
		
		[phoneImageView addSubview:_previewBubble];
		[self addSubview:phoneImageView];
		
		bbcontroller.previewCell = self;
		
//		[self syncBubbleSize];
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
	float size = [[bbcontroller readPreferenceValue:bbcontroller.sliderSpec] floatValue];
//	if (size > 0) {
		DebugLog(@"setting for slider = %f; adjusting bubble...", size);
		[self scaleBubble:size];
//	}
}
@end



// Slider Cell -----------------------------------------------------------------

@implementation MGBBSliderCell
- (id)initWithStyle:(long long)style reuseIdentifier:(id)reuseIdentifier specifier:(PSSpecifier *)sliderSpec {
	DebugLog0;
	
	static NSString *cellID = @"myMGBBSliderCell";
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID specifier:sliderSpec];
	
	if (self) {
		
		// configure the slider based on current device size ...
		[sliderSpec setProperty:[NSNumber numberWithFloat:[bbcontroller sizeForSize:@"min"]] forKey:@"min"];
		[sliderSpec setProperty:[NSNumber numberWithFloat:[bbcontroller sizeForSize:@"max"]] forKey:@"max"];
		[sliderSpec setProperty:[NSNumber numberWithFloat:[bbcontroller sizeForSize:@"default"]] forKey:@"default"];
		
		UISlider *slider = (UISlider *)_control;
		DebugLog(@"UISlider obj = %@", slider);
		
		slider.minimumTrackTintColor = PINK;
		slider.maximumTrackTintColor = PURPLE;
		
		// UIControlEventValueChanged isn't firing continuously, so I'm using TouchDragInside instead
		[slider addTarget:self.specifier.target action:@selector(sliderMoved:) forControlEvents:UIControlEventTouchDragInside];
		
		[self disableSliderIfNecessary];
	}
	return self;
}
- (void)disableSliderIfNecessary {
	
	DebugLog(@"sizeListSpec=%@", bbcontroller.sizeListSpec);
	NSString *setting = [bbcontroller readPreferenceValue:bbcontroller.sizeListSpec];
	DebugLog(@"setting? %@", setting);
	
	UISlider *slider = (UISlider *)_control;

	if ([setting isEqualToString:@"custom"]) {
		DebugLog(@"> enable slider");
		slider.enabled = YES;
	} else {
		DebugLog(@"> disable slider");
		slider.enabled = NO;
	}
}
@end

