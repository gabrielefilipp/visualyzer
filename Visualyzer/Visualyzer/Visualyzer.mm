#line 1 "/Users/gabrielefilipponi/Documents/GitHub/visualyzer/Visualyzer/Visualyzer/Visualyzer.xm"
#import "Header.h"
#import "Views/VisualyzerView.h"


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class _UIStatusBarStringView; @class _UIStatusBarCellularItem; @class SBBacklightController; @class SBMediaController; @class _UIStatusBarTimeItem; 

static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBMediaController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBMediaController"); } return _klass; }
#line 4 "/Users/gabrielefilipponi/Documents/GitHub/visualyzer/Visualyzer/Visualyzer/Visualyzer.xm"
static void (*_logos_orig$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$)(_LOGOS_SELF_TYPE_NORMAL SBMediaController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$(_LOGOS_SELF_TYPE_NORMAL SBMediaController* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$TWEAK$SBBacklightController$setBacklightFactorPending$)(_LOGOS_SELF_TYPE_NORMAL SBBacklightController* _LOGOS_SELF_CONST, SEL, float); static void _logos_method$TWEAK$SBBacklightController$setBacklightFactorPending$(_LOGOS_SELF_TYPE_NORMAL SBBacklightController* _LOGOS_SELF_CONST, SEL, float); static _UIStatusBarTimeItem* (*_logos_orig$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$)(_LOGOS_SELF_TYPE_INIT _UIStatusBarTimeItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static _UIStatusBarTimeItem* _logos_method$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarTimeItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarTimeItem$setShortTimeView$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarStringView *); static void _logos_method$TWEAK$_UIStatusBarTimeItem$setShortTimeView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarStringView *); static _UIStatusBarCellularItem* (*_logos_orig$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$)(_LOGOS_SELF_TYPE_INIT _UIStatusBarCellularItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static _UIStatusBarCellularItem* _logos_method$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarCellularItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarCellularItem$setServiceNameView$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarStringView *); static void _logos_method$TWEAK$_UIStatusBarCellularItem$setServiceNameView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarStringView *); static _UIStatusBarStringView* (*_logos_orig$TWEAK$_UIStatusBarStringView$initWithFrame$)(_LOGOS_SELF_TYPE_INIT _UIStatusBarStringView*, SEL, CGRect) _LOGOS_RETURN_RETAINED; static _UIStatusBarStringView* _logos_method$TWEAK$_UIStatusBarStringView$initWithFrame$(_LOGOS_SELF_TYPE_INIT _UIStatusBarStringView*, SEL, CGRect) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$TWEAK$_UIStatusBarStringView$didMoveToWindow)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarStringView$didMoveToWindow(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$movedToSuperview$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, UIView *); static void _logos_method$TWEAK$_UIStatusBarStringView$movedToSuperview$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, UIView *); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$layoutSubviews)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarStringView$layoutSubviews(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$setFrame$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, CGRect); static void _logos_method$TWEAK$_UIStatusBarStringView$setFrame$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, CGRect); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$removeFromSuperview)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarStringView$removeFromSuperview(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$setText$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, NSString*); static void _logos_method$TWEAK$_UIStatusBarStringView$setText$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, NSString*); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$setTextColor$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, UIColor *); static void _logos_method$TWEAK$_UIStatusBarStringView$setTextColor$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, UIColor *); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$dealloc)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarStringView$dealloc(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static BOOL (*_logos_orig$TWEAK$_UIStatusBarStringView$isHidden)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static BOOL _logos_method$TWEAK$_UIStatusBarStringView$isHidden(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$setHidden$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$TWEAK$_UIStatusBarStringView$setHidden$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, BOOL); 



static void _logos_method$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$(_LOGOS_SELF_TYPE_NORMAL SBMediaController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    _logos_orig$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$(self, _cmd, arg1);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerMediaNotification" object:@([self isPlaying])];
}





static void _logos_method$TWEAK$SBBacklightController$setBacklightFactorPending$(_LOGOS_SELF_TYPE_NORMAL SBBacklightController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, float value) {
    _logos_orig$TWEAK$SBBacklightController$setBacklightFactorPending$(self, _cmd, value);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightNotification" object:@(value)];
};





static _UIStatusBarTimeItem* _logos_method$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarTimeItem* __unused self, SEL __unused _cmd, id arg1, id arg2) _LOGOS_RETURN_RETAINED {
    _UIStatusBarTimeItem *orig = _logos_orig$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$(self, _cmd, arg1, arg2);
    if (orig) {
        [[orig shortTimeView] setShortTime:YES];
    }
    return orig;
}

static void _logos_method$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView(self, _cmd);
    [[self shortTimeView] setShortTime:YES];
}

static void _logos_method$TWEAK$_UIStatusBarTimeItem$setShortTimeView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, _UIStatusBarStringView * arg1) {
    [arg1 setShortTime:YES];
}





static _UIStatusBarCellularItem* _logos_method$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarCellularItem* __unused self, SEL __unused _cmd, id arg1, id arg2) _LOGOS_RETURN_RETAINED {
    _UIStatusBarCellularItem *orig = _logos_orig$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$(self, _cmd, arg1, arg2);
    if (orig) {
        [[orig serviceNameView] setShortTime:YES];
    }
    return orig;
}

static void _logos_method$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView(self, _cmd);
    [[self serviceNameView] setShortTime:YES];
}

static void _logos_method$TWEAK$_UIStatusBarCellularItem$setServiceNameView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, _UIStatusBarStringView * arg1) {
    [arg1 setShortTime:YES];
}





__attribute__((used)) static VisualyzerView * _logos_method$TWEAK$_UIStatusBarStringView$vizView(_UIStatusBarStringView * __unused self, SEL __unused _cmd) { return (VisualyzerView *)objc_getAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarStringView$vizView); }; __attribute__((used)) static void _logos_method$TWEAK$_UIStatusBarStringView$setVizView(_UIStatusBarStringView * __unused self, SEL __unused _cmd, VisualyzerView * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarStringView$vizView, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
__attribute__((used)) static BOOL _logos_method$TWEAK$_UIStatusBarStringView$shortTime(_UIStatusBarStringView * __unused self, SEL __unused _cmd) { NSValue * value = objc_getAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarStringView$shortTime); BOOL rawValue; [value getValue:&rawValue]; return rawValue; }; __attribute__((used)) static void _logos_method$TWEAK$_UIStatusBarStringView$setShortTime(_UIStatusBarStringView * __unused self, SEL __unused _cmd, BOOL rawValue) { NSValue * value = [NSValue valueWithBytes:&rawValue objCType:@encode(BOOL)]; objc_setAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarStringView$shortTime, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

static _UIStatusBarStringView* _logos_method$TWEAK$_UIStatusBarStringView$initWithFrame$(_LOGOS_SELF_TYPE_INIT _UIStatusBarStringView* __unused self, SEL __unused _cmd, CGRect frame) _LOGOS_RETURN_RETAINED {
    _UIStatusBarStringView *orig = _logos_orig$TWEAK$_UIStatusBarStringView$initWithFrame$(self, _cmd, frame);
    if (orig) {
        orig.shortTime = NO;
        orig.vizView = [[VisualyzerView alloc] initWithFrame:frame];
        orig.vizView.parent = orig;
    }
    return orig;
}

static void _logos_method$TWEAK$_UIStatusBarStringView$didMoveToWindow(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarStringView$didMoveToWindow(self, _cmd);
    if ([[_logos_static_class_lookup$SBMediaController() sharedInstance] isPlaying] && self.shortTime) {
        self.hidden = YES;
        self.vizView.hidden = NO;
        [self.vizView setFrame:self.frame];
    }else{
        self.hidden = NO;
        self.vizView.hidden = YES;
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$movedToSuperview$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIView * superview) {
    _logos_orig$TWEAK$_UIStatusBarStringView$movedToSuperview$(self, _cmd, superview);
    if (self.vizView) {
        [self.vizView setFrame:self.frame];
        [superview addSubview:self.vizView];
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$layoutSubviews(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarStringView$layoutSubviews(self, _cmd);
    if (self.vizView) {
        [self.vizView setFrame:self.frame];
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$setFrame$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, CGRect frame) {
    _logos_orig$TWEAK$_UIStatusBarStringView$setFrame$(self, _cmd, frame);
    if (self.vizView) {
        [self.vizView setFrame:self.frame];
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$removeFromSuperview(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarStringView$removeFromSuperview(self, _cmd);
    if (self.vizView) {
        [self.vizView removeFromSuperview];
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$setText$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSString* arg1) {
    _logos_orig$TWEAK$_UIStatusBarStringView$setText$(self, _cmd, arg1);
    if (self.vizView) {
        [self.vizView setFrame:self.frame];
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$setTextColor$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIColor * textColor) {
    _logos_orig$TWEAK$_UIStatusBarStringView$setTextColor$(self, _cmd, textColor);
    if (self.vizView) {
        self.vizView.pointColor = textColor;
        [self.vizView setFrame:self.frame];
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$dealloc(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if (self.vizView) {
        self.vizView.parent = NULL;
        [self.vizView removeFromSuperview];
        self.vizView = NULL;
    }
    _logos_orig$TWEAK$_UIStatusBarStringView$dealloc(self, _cmd);
}

static BOOL _logos_method$TWEAK$_UIStatusBarStringView$isHidden(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if ([[_logos_static_class_lookup$SBMediaController() sharedInstance] isPlaying] && self.shortTime) {
        return YES;
    }
    return _logos_orig$TWEAK$_UIStatusBarStringView$isHidden(self, _cmd);
}

static void _logos_method$TWEAK$_UIStatusBarStringView$setHidden$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL hidden) {
    if ([[_logos_static_class_lookup$SBMediaController() sharedInstance] isPlaying] && self.shortTime) {
        return _logos_orig$TWEAK$_UIStatusBarStringView$setHidden$(self, _cmd, YES);
    }
    return _logos_orig$TWEAK$_UIStatusBarStringView$setHidden$(self, _cmd, hidden);
}





static __attribute__((constructor)) void _logosLocalCtor_a72702ea(int __unused argc, char __unused **argv, char __unused **envp) {
    {Class _logos_class$TWEAK$SBMediaController = objc_getClass("SBMediaController"); MSHookMessageEx(_logos_class$TWEAK$SBMediaController, @selector(_mediaRemoteNowPlayingApplicationIsPlayingDidChange:), (IMP)&_logos_method$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$, (IMP*)&_logos_orig$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$);Class _logos_class$TWEAK$SBBacklightController = objc_getClass("SBBacklightController"); MSHookMessageEx(_logos_class$TWEAK$SBBacklightController, @selector(setBacklightFactorPending:), (IMP)&_logos_method$TWEAK$SBBacklightController$setBacklightFactorPending$, (IMP*)&_logos_orig$TWEAK$SBBacklightController$setBacklightFactorPending$);Class _logos_class$TWEAK$_UIStatusBarTimeItem = objc_getClass("_UIStatusBarTimeItem"); MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarTimeItem, @selector(initWithIdentifier:statusBar:), (IMP)&_logos_method$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarTimeItem, @selector(_create_shortTimeView), (IMP)&_logos_method$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView, (IMP*)&_logos_orig$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarTimeItem, @selector(setShortTimeView:), (IMP)&_logos_method$TWEAK$_UIStatusBarTimeItem$setShortTimeView$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarTimeItem$setShortTimeView$);Class _logos_class$TWEAK$_UIStatusBarCellularItem = objc_getClass("_UIStatusBarCellularItem"); MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarCellularItem, @selector(initWithIdentifier:statusBar:), (IMP)&_logos_method$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarCellularItem, @selector(_create_serviceNameView), (IMP)&_logos_method$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView, (IMP*)&_logos_orig$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarCellularItem, @selector(setServiceNameView:), (IMP)&_logos_method$TWEAK$_UIStatusBarCellularItem$setServiceNameView$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarCellularItem$setServiceNameView$);Class _logos_class$TWEAK$_UIStatusBarStringView = objc_getClass("_UIStatusBarStringView"); MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(initWithFrame:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$initWithFrame$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$initWithFrame$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(didMoveToWindow), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$didMoveToWindow, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$didMoveToWindow);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(movedToSuperview:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$movedToSuperview$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$movedToSuperview$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(layoutSubviews), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$layoutSubviews, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$layoutSubviews);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(setFrame:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$setFrame$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$setFrame$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(removeFromSuperview), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$removeFromSuperview, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$removeFromSuperview);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(setText:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$setText$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$setText$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(setTextColor:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$setTextColor$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$setTextColor$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, sel_registerName("dealloc"), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$dealloc, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$dealloc);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(isHidden), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$isHidden, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$isHidden);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(setHidden:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$setHidden$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$setHidden$);{ char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(VisualyzerView *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarStringView, @selector(vizView), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$vizView, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(VisualyzerView *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarStringView, @selector(setVizView:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$setVizView, _typeEncoding); } { char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(BOOL)); class_addMethod(_logos_class$TWEAK$_UIStatusBarStringView, @selector(shortTime), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$shortTime, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(BOOL)); class_addMethod(_logos_class$TWEAK$_UIStatusBarStringView, @selector(setShortTime:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$setShortTime, _typeEncoding); } }
}
