//
//  Big Bubbles
//	Bigger chat bubbles for image previews in the Messages App.
//  Copied from iOS 8.
//
//  Created by Sticktron.
//  Copyright (c) 2014. All rights reserved.
//
//
//  Hierarchy (base class > subclass > subclass > etc.):
//    UIImageView > CKBalloonImageView > CKBalloonView > CKImageBalloonView
//    UICollectionViewCell > CKEditableCollectionViewCell > CKTranscriptCell > CKTranscriptMessageCell > CKTranscriptBalloonCell
//
//

//deviceconsole | grep 'BigBubbles' | awk '{gsub(/@@@/,"\n")}1

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <ChatKit/CKBalloonImageView.h>
#import <ChatKit/CKBalloonView.h>
#import <ChatKit/CKConversation.h>
#import <ChatKit/CKImageBalloonView.h>
#import <ChatKit/CKImageData.h>
#import <ChatKit/CKImageMediaObject.h>
#import <ChatKit/CKMediaObject.h>
#import <ChatKit/CKMediaObjectManager.h>
#import <ChatKit/CKMessagePart.h>
#import <ChatKit/CKPreviewDispatchCache.h>
#import <ChatKit/CKTranscriptBalloonCell.h>
#import <ChatKit/CKTranscriptController.h>
#import <ChatKit/CKTranscriptDataRow.h>
#import <ChatKit/CKTranscriptDataRowSize.h>
#import <ChatKit/CKUIBehavior.h>

#ifdef DEBUG
	#define DebugLog(s, ...) \
			NSLog(@"BigBubbles >> %@::%@ >> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [NSString stringWithFormat:(s), ##__VA_ARGS__])
	#define DebugLogC(s, ...) \
			NSLog(@"BigBubbles >> %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
	#define DebugLog(s, ...)
	#define DebugLogC(s, ...)
#endif



#define iOS_7			(kCFCoreFoundationVersionNumber >= 847.20)
#define WIDTH_IPHONE	280.0f
#define WIDTH_IPAD		320.0f



static inline CGSize bigSizeFromSize(CGSize size) {
    CGSize result;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		result.width = WIDTH_IPAD;
	} else {
		result.width = WIDTH_IPHONE;
	}
	
    result.height = (result.width / size.width) * size.height;
    DebugLogC(@"resizing from:%@ to %@", NSStringFromCGSize(size), NSStringFromCGSize(result));
    return result;
}



////////////////////////////////////////////////////////////////////////////////



%group iOS7

%hook CKUIBehavior

- (CGSize)thumbnailFillSizeForImageSize:(CGSize)size {
	CGSize fillSize = %orig;
	DebugLog(@"original value=%@", NSStringFromCGSize(fillSize));
	
	CGSize newSize = bigSizeFromSize(fillSize);
	DebugLog(@">> returning: %@", NSStringFromCGSize(newSize));
	
	return newSize;
}

%end

%end //iOS7



////////////////////////////////////////////////////////////////////////////////



%group iOS6

%hook CKUIBehavior

- (struct CGSize)videoPreviewBalloonImageMaxSize {
	CGSize size = %orig;
	DebugLog(@"original value=%@", NSStringFromCGSize(size));
	
	CGSize newSize = bigSizeFromSize(size);
	DebugLog(@">> returning: %@", NSStringFromCGSize(newSize));
	
	return newSize;
}

- (struct CGSize)previewBalloonImageMaxSize {
	CGSize size = %orig;
	DebugLog(@"original value=%@", NSStringFromCGSize(size));
	
	CGSize newSize = bigSizeFromSize(size);
	DebugLog(@">> returning: %@", NSStringFromCGSize(newSize));
	
	return newSize;
}

//- (struct CGSize)previewThumbnailMaxSize {
//	CGSize size = %orig;
//	DebugLog(@"original value=%@", NSStringFromCGSize(size));
//	
//	CGSize newSize = bigSizeFromSize(size);
//	DebugLog(@">> returning: %@", NSStringFromCGSize(newSize));
//	
//	return newSize;
//}

//- (struct CGSize)balloonImageSize { %log; struct CGSize r = %orig; return r; }

%end

%end //iOS6



////////////////////////////////////////////////////////////////////////////////



%ctor {
    @autoreleasepool {
        NSLog(@" BigBubbles loaded");
		if (iOS_7) {
			%init(iOS7);
		} else {
			%init(iOS6);
		}
	}
}

