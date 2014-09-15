ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:6.0
THEOS_BUILD_DIR = Packages

BUNDLE_NAME = BigBubblesSettings
BigBubblesSettings_CFLAGS = -fobjc-arc
BigBubblesSettings_FILES = BigBubblesSettings.m
BigBubblesSettings_INSTALL_PATH = /Library/PreferenceBundles
BigBubblesSettings_FRAMEWORKS = Foundation UIKit CoreGraphics
BigBubblesSettings_PRIVATE_FRAMEWORKS = Preferences

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BigBubblesSettings.plist$(ECHO_END)
