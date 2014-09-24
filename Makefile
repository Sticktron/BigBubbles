ARCHS = armv7 arm64
TARGET = iphone:clang:latest:6.0

THEOS_BUILD_DIR = Packages

TWEAK_NAME = BigBubbles
BigBubbles_CFLAGS = -fobjc-arc
BigBubbles_FILES = Tweak.xm
BigBubbles_FRAMEWORKS = Foundation UIKit CoreGraphics
BigBubbles_PRIVATE_FRAMEWORKS = ChatKit

SUBPROJECTS += Settings

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-stage::
	find $(FW_STAGING_DIR) -iname '*.plist' -or -iname '*.strings' -exec plutil -convert binary1 {} \;
	find $(FW_STAGING_DIR) -iname '*.png' -exec pincrush-osx -i {} \;

after-install::
	install.exec "killall -9 MobileSMS; killall -9 Preferences"
