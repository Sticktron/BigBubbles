ARCHS = armv7 armv7s arm64
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

after-install::
	install.exec "killall -9 MobileSMS; killall -9 Preferences"