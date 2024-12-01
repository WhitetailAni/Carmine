#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.whitetailani.Carmine";

/// The "AccentColor" asset catalog color resource.
static NSString * const ACColorNameAccentColor AC_SWIFT_PRIVATE = @"AccentColor";

/// The "Carmine" asset catalog image resource.
static NSString * const ACImageNameCarmine AC_SWIFT_PRIVATE = @"Carmine";

/// The "busTracker" asset catalog image resource.
static NSString * const ACImageNameBusTracker AC_SWIFT_PRIVATE = @"busTracker";

/// The "cta" asset catalog image resource.
static NSString * const ACImageNameCta AC_SWIFT_PRIVATE = @"cta";

/// The "ctaBus" asset catalog image resource.
static NSString * const ACImageNameCtaBus AC_SWIFT_PRIVATE = @"ctaBus";

/// The "pace" asset catalog image resource.
static NSString * const ACImageNamePace AC_SWIFT_PRIVATE = @"pace";

#undef AC_SWIFT_PRIVATE
