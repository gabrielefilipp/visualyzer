#line 1 "/Users/gabrielefilipponi/Documents/GitHub/visualyzer/Visualyzer/Visualyzer/Visualyzer.xm"
#import "Header.h"
#import "Views/VisualyzerView.h"

#import <AudioToolbox/AudioToolbox.h>
#import <arpa/inet.h>
#include <os/log.h>
#include <substrate.h>

#define ASSPort 43333

AudioBufferList *p_bufferlist = NULL;
Float64 rate = 0;
UInt32 depth = 0;

OSStatus (*orig_AudioUnitRender)(AudioUnit unit, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inOutputBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData);
OSStatus function_AudioUnitRender(AudioUnit unit, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inOutputBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    AudioComponentDescription unitDescription = { 0 };
    AudioComponentGetDescription(AudioComponentInstanceGetComponent(unit), &unitDescription);
    
    if (unitDescription.componentSubType == 'mcmx') {
        if (inNumberFrames > 0) {
            
            AudioStreamBasicDescription streamDescription = { 0 };
            UInt32 size = sizeof(AudioStreamBasicDescription);
            OSStatus status = AudioUnitGetProperty(unit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &streamDescription, &size);
            if (status == kAudioServicesNoError) {
                rate = streamDescription.mSampleRate;
                depth = streamDescription.mBitsPerChannel;
            }else{
                rate = 0;
                depth = 0;
            }
            
            p_bufferlist = ioData;
        } else {
            p_bufferlist = NULL;
        }
    }

    return orig_AudioUnitRender(unit, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, ioData);
}

void handle_connection(const int connfd) {
    os_log(OS_LOG_DEFAULT, "[ASS] [%d] Connection opened.", connfd);

    struct timeval tv;
    tv.tv_sec = 5;
    tv.tv_usec = 0;

    UInt32 len = sizeof(float);
    int rlen = 0;
    float *data = NULL;
    float empty = 0.0f;
    char buffer[128];

    fd_set readset;
    int result = -1;
    FD_ZERO(&readset);
    FD_SET(connfd, &readset);

    while(connfd != -1) {
        result = select(connfd+1, &readset, NULL, NULL, &tv);

        if (result < 0) {
            close(connfd);
            break;
        }
        
        
        rlen = recv(connfd, buffer, sizeof(buffer), 0);
        if (rlen <= 0) {
            if (rlen == 0) {
                close(connfd);
            }
            break;
        }

        
        data = NULL;

        if (p_bufferlist != NULL) {
            len = (*p_bufferlist).mBuffers[0].mDataByteSize;
            data = (float *)(*p_bufferlist).mBuffers[0].mData;
        } else {
            len = sizeof(float);
            data = &empty;
        }

        rlen = send(connfd, &len, sizeof(UInt32), 0);
        if (rlen > 0) {
            rlen = send(connfd, data, len, 0);
            if (rlen > 0) {
                rlen = send(connfd, &rate, sizeof(Float64), 0);
                if (rlen > 0) {
                    rlen = send(connfd, &depth, sizeof(UInt32), 0);
                }
            }
        }
        
        if (rlen <= 0) {
            if (rlen == 0) {
                close(connfd);
            }
            break;
        }
    }

    os_log(OS_LOG_DEFAULT, "[ASS] [%d] Connection closed.", connfd);
}

void server() {
    os_log(OS_LOG_DEFAULT, "[ASS] Server created...");
    struct sockaddr_in local;
    memset(&local, 0, sizeof(local));
    local.sin_family = AF_INET;
    local.sin_addr.s_addr = htonl(INADDR_LOOPBACK); 
    local.sin_port = htons(ASSPort);
    int listenfd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

    int r = -1;
    while(r != 0) {
        r = bind(listenfd, (struct sockaddr*)&local, sizeof(local));
        usleep(200 * 1000);
    }
    os_log(OS_LOG_DEFAULT, "[ASSWatchdog] abort, there's no ASS here...");

    const int one = 1;
    setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
    setsockopt(listenfd, SOL_SOCKET, SO_REUSEPORT, &one, sizeof(one));
    setsockopt(listenfd, SOL_SOCKET, SO_NOSIGPIPE, &one, sizeof(one));

    r = -1;
    while(r != 0) {
        r = listen(listenfd, 20);
        usleep(200 * 1000);
    }
    os_log(OS_LOG_DEFAULT, "[ASS] Listening");

    while(true) {
        const int connfd = accept(listenfd, (struct sockaddr*)NULL, NULL);
        if (connfd > 0) {
            struct timeval tv;
            tv.tv_sec = 5;
            tv.tv_usec = 0;
            setsockopt(connfd, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof tv);
            setsockopt(connfd, SOL_SOCKET, SO_SNDTIMEO, (const char*)&tv, sizeof tv);
            setsockopt(connfd, SOL_SOCKET, SO_NOSIGPIPE, &one, sizeof(one));
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                handle_connection(connfd);
            });
        }
    }
}


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

@class _UIStatusBarImageView; @class _UIStatusBarCellularItem; @class _UIStatusBarIndicatorAirplaneModeItem; @class SBBacklightController; @class _UIStatusBarTimeItem; @class _UIStatusBarDisplayItem; @class SBMediaController; @class _UIStatusBarStringView; 

static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBMediaController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBMediaController"); } return _klass; }static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$_UIStatusBarIndicatorAirplaneModeItem(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("_UIStatusBarIndicatorAirplaneModeItem"); } return _klass; }
#line 155 "/Users/gabrielefilipponi/Documents/GitHub/visualyzer/Visualyzer/Visualyzer/Visualyzer.xm"
static void (*_logos_orig$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$)(_LOGOS_SELF_TYPE_NORMAL SBMediaController* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$(_LOGOS_SELF_TYPE_NORMAL SBMediaController* _LOGOS_SELF_CONST, SEL, id); static float _logos_method$TWEAK$SBMediaController$volume(_LOGOS_SELF_TYPE_NORMAL SBMediaController* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$SBBacklightController$setBacklightFactorPending$)(_LOGOS_SELF_TYPE_NORMAL SBBacklightController* _LOGOS_SELF_CONST, SEL, float); static void _logos_method$TWEAK$SBBacklightController$setBacklightFactorPending$(_LOGOS_SELF_TYPE_NORMAL SBBacklightController* _LOGOS_SELF_CONST, SEL, float); static _UIStatusBarDisplayItem* (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$initWithIdentifier$item$)(_LOGOS_SELF_TYPE_INIT _UIStatusBarDisplayItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static _UIStatusBarDisplayItem* _logos_method$TWEAK$_UIStatusBarDisplayItem$initWithIdentifier$item$(_LOGOS_SELF_TYPE_INIT _UIStatusBarDisplayItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static void _logos_method$TWEAK$_UIStatusBarDisplayItem$dispatchVizContainerView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$setContainerView$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, UIView *); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setContainerView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, UIView *); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$setLayoutItem$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setLayoutItem$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$setAbsoluteFrame$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, CGRect); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setAbsoluteFrame$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, CGRect); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$setCenterOffset$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, double); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setCenterOffset$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, double); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$setEnabled$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setEnabled$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, BOOL); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$applyStyleAttributes$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$applyStyleAttributes$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$setPlacement$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setPlacement$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$setViewTransform$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, CGAffineTransform); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setViewTransform$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, CGAffineTransform); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$setBaselineOffset$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, double); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setBaselineOffset$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, double); static void (*_logos_orig$TWEAK$_UIStatusBarDisplayItem$setRegion$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setRegion$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST, SEL, id); static _UIStatusBarIndicatorAirplaneModeItem* (*_logos_orig$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$initWithIdentifier$statusBar$)(_LOGOS_SELF_TYPE_INIT _UIStatusBarIndicatorAirplaneModeItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static _UIStatusBarIndicatorAirplaneModeItem* _logos_method$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarIndicatorAirplaneModeItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$_create_imageView)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarIndicatorAirplaneModeItem* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$_create_imageView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarIndicatorAirplaneModeItem* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$setImageView$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarIndicatorAirplaneModeItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarImageView *); static void _logos_method$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$setImageView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarIndicatorAirplaneModeItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarImageView *); static _UIStatusBarTimeItem* (*_logos_orig$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$)(_LOGOS_SELF_TYPE_INIT _UIStatusBarTimeItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static _UIStatusBarTimeItem* _logos_method$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarTimeItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarTimeItem$setShortTimeView$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarStringView *); static void _logos_method$TWEAK$_UIStatusBarTimeItem$setShortTimeView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarStringView *); static _UIStatusBarCellularItem* (*_logos_orig$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$)(_LOGOS_SELF_TYPE_INIT _UIStatusBarCellularItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static _UIStatusBarCellularItem* _logos_method$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarCellularItem*, SEL, id, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarCellularItem$setServiceNameView$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarStringView *); static void _logos_method$TWEAK$_UIStatusBarCellularItem$setServiceNameView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST, SEL, _UIStatusBarStringView *); static _UIStatusBarImageView* (*_logos_orig$TWEAK$_UIStatusBarImageView$initWithFrame$)(_LOGOS_SELF_TYPE_INIT _UIStatusBarImageView*, SEL, CGRect) _LOGOS_RETURN_RETAINED; static _UIStatusBarImageView* _logos_method$TWEAK$_UIStatusBarImageView$initWithFrame$(_LOGOS_SELF_TYPE_INIT _UIStatusBarImageView*, SEL, CGRect) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$TWEAK$_UIStatusBarImageView$didMoveToWindow)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarImageView$didMoveToWindow(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarImageView$movedToSuperview$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST, SEL, UIView *); static void _logos_method$TWEAK$_UIStatusBarImageView$movedToSuperview$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST, SEL, UIView *); static void (*_logos_orig$TWEAK$_UIStatusBarImageView$removeFromSuperview)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarImageView$removeFromSuperview(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarImageView$dealloc)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarImageView$dealloc(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST, SEL); static _UIStatusBarStringView* (*_logos_orig$TWEAK$_UIStatusBarStringView$initWithFrame$)(_LOGOS_SELF_TYPE_INIT _UIStatusBarStringView*, SEL, CGRect) _LOGOS_RETURN_RETAINED; static _UIStatusBarStringView* _logos_method$TWEAK$_UIStatusBarStringView$initWithFrame$(_LOGOS_SELF_TYPE_INIT _UIStatusBarStringView*, SEL, CGRect) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$TWEAK$_UIStatusBarStringView$didMoveToWindow)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarStringView$didMoveToWindow(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$movedToSuperview$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, UIView *); static void _logos_method$TWEAK$_UIStatusBarStringView$movedToSuperview$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, UIView *); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$setTextColor$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, UIColor *); static void _logos_method$TWEAK$_UIStatusBarStringView$setTextColor$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, UIColor *); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$removeFromSuperview)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarStringView$removeFromSuperview(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static BOOL (*_logos_orig$TWEAK$_UIStatusBarStringView$isHidden)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static BOOL _logos_method$TWEAK$_UIStatusBarStringView$isHidden(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$setHidden$)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, BOOL); static void _logos_method$TWEAK$_UIStatusBarStringView$setHidden$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL, BOOL); static void (*_logos_orig$TWEAK$_UIStatusBarStringView$dealloc)(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); static void _logos_method$TWEAK$_UIStatusBarStringView$dealloc(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST, SEL); 



static void _logos_method$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$(_LOGOS_SELF_TYPE_NORMAL SBMediaController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    _logos_orig$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$(self, _cmd, arg1);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerMediaNotification" object:@([self isPlaying])];
}


static float _logos_method$TWEAK$SBMediaController$volume(_LOGOS_SELF_TYPE_NORMAL SBMediaController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    SBVolumeControl *control = MSHookIvar<SBVolumeControl *>(self, "_volumeControl");
    if (control) {
        return [control _effectiveVolume];
    }
    return 0.0f;
}





static void _logos_method$TWEAK$SBBacklightController$setBacklightFactorPending$(_LOGOS_SELF_TYPE_NORMAL SBBacklightController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, float value) {
    _logos_orig$TWEAK$SBBacklightController$setBacklightFactorPending$(self, _cmd, value);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightNotification" object:@(value)];
};





__attribute__((used)) static UIView * _logos_method$TWEAK$_UIStatusBarDisplayItem$vizContainerView(_UIStatusBarDisplayItem * __unused self, SEL __unused _cmd) { return (UIView *)objc_getAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarDisplayItem$vizContainerView); }; __attribute__((used)) static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setVizContainerView(_UIStatusBarDisplayItem * __unused self, SEL __unused _cmd, UIView * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarDisplayItem$vizContainerView, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

static _UIStatusBarDisplayItem* _logos_method$TWEAK$_UIStatusBarDisplayItem$initWithIdentifier$item$(_LOGOS_SELF_TYPE_INIT _UIStatusBarDisplayItem* __unused self, SEL __unused _cmd, id arg1, id arg2) _LOGOS_RETURN_RETAINED {
    _UIStatusBarDisplayItem *item = _logos_orig$TWEAK$_UIStatusBarDisplayItem$initWithIdentifier$item$(self, _cmd, arg1, arg2);
    if (item) {
        [item dispatchVizContainerView];
    }
    return item;
}


static void _logos_method$TWEAK$_UIStatusBarDisplayItem$dispatchVizContainerView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if ([self item] && [[self item] isKindOfClass:_logos_static_class_lookup$_UIStatusBarIndicatorAirplaneModeItem()]) {
        if (!self.vizContainerView) {
            self.vizContainerView = [[UIView alloc] init];
            self.vizContainerView.backgroundColor = [UIColor clearColor];
        }
        if ([self isEnabled] && [self visible] && ![[[self region] identifier] isEqualToString:@"trailing"]) {
            self.vizContainerView.hidden = NO;
            [[self containerView] addSubview:self.vizContainerView];
            
            
            self.vizContainerView.frame = CGRectMake(self.view.frame.origin.x + self.view.frame.size.width, 0.0, self.containerView.frame.size.width - (self.view.frame.origin.x + self.view.frame.size.width), self.containerView.frame.size.height);
            
            ((_UIStatusBarImageView *)[self view]).displayItem = self;
            [[self containerView] addSubview:[((_UIStatusBarImageView *)[self view]) vizView]];
            [[((_UIStatusBarImageView *)[self view]) vizView] setParent:self.vizContainerView];
        }else{
            [((_UIStatusBarImageView *)[self view]) vizView].hidden = YES;
        }
    }
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setContainerView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIView * arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$setContainerView$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setLayoutItem$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$setLayoutItem$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setAbsoluteFrame$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, CGRect arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$setAbsoluteFrame$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setCenterOffset$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, double arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$setCenterOffset$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setEnabled$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$setEnabled$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$applyStyleAttributes$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$applyStyleAttributes$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setPlacement$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$setPlacement$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setViewTransform$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, CGAffineTransform arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$setViewTransform$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setBaselineOffset$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, double arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$setBaselineOffset$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}

static void _logos_method$TWEAK$_UIStatusBarDisplayItem$setRegion$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarDisplayItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    _logos_orig$TWEAK$_UIStatusBarDisplayItem$setRegion$(self, _cmd, arg1);
    [self dispatchVizContainerView];
}





static _UIStatusBarIndicatorAirplaneModeItem* _logos_method$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarIndicatorAirplaneModeItem* __unused self, SEL __unused _cmd, id arg1, id arg2) _LOGOS_RETURN_RETAINED {
    _UIStatusBarIndicatorAirplaneModeItem *item = _logos_orig$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$initWithIdentifier$statusBar$(self, _cmd, arg1, arg2);
    if (item) {
        [[[item imageView] vizView] setRender:YES];
    }
    return item;
}

static void _logos_method$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$_create_imageView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarIndicatorAirplaneModeItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$_create_imageView(self, _cmd);
    [[[self imageView] vizView] setRender:YES];
}

static void _logos_method$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$setImageView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarIndicatorAirplaneModeItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, _UIStatusBarImageView * arg1) {
    _logos_orig$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$setImageView$(self, _cmd, arg1);
    [[arg1 vizView] setRender:YES];
}





static _UIStatusBarTimeItem* _logos_method$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarTimeItem* __unused self, SEL __unused _cmd, id arg1, id arg2) _LOGOS_RETURN_RETAINED {
    _UIStatusBarTimeItem *orig = _logos_orig$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$(self, _cmd, arg1, arg2);
    if (orig) {
        [[[orig shortTimeView] vizView] setRender:YES];
    }
    return orig;
}

static void _logos_method$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView(self, _cmd);
    [[[self shortTimeView] vizView] setRender:YES];
}

static void _logos_method$TWEAK$_UIStatusBarTimeItem$setShortTimeView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarTimeItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, _UIStatusBarStringView * arg1) {
    [[arg1 vizView] setRender:YES];
}





static _UIStatusBarCellularItem* _logos_method$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$(_LOGOS_SELF_TYPE_INIT _UIStatusBarCellularItem* __unused self, SEL __unused _cmd, id arg1, id arg2) _LOGOS_RETURN_RETAINED {
    _UIStatusBarCellularItem *orig = _logos_orig$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$(self, _cmd, arg1, arg2);
    if (orig) {
        [[[orig serviceNameView] vizView] setRender:YES];
    }
    return orig;
}

static void _logos_method$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView(self, _cmd);
    [[[self serviceNameView] vizView] setRender:YES];
}

static void _logos_method$TWEAK$_UIStatusBarCellularItem$setServiceNameView$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarCellularItem* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, _UIStatusBarStringView * arg1) {
    [[arg1 vizView] setRender:YES];
}





__attribute__((used)) static _UIStatusBarDisplayItem * _logos_method$TWEAK$_UIStatusBarImageView$displayItem(_UIStatusBarImageView * __unused self, SEL __unused _cmd) { return (_UIStatusBarDisplayItem *)objc_getAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarImageView$displayItem); }; __attribute__((used)) static void _logos_method$TWEAK$_UIStatusBarImageView$setDisplayItem(_UIStatusBarImageView * __unused self, SEL __unused _cmd, _UIStatusBarDisplayItem * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarImageView$displayItem, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
__attribute__((used)) static VisualyzerView * _logos_method$TWEAK$_UIStatusBarImageView$vizView(_UIStatusBarImageView * __unused self, SEL __unused _cmd) { return (VisualyzerView *)objc_getAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarImageView$vizView); }; __attribute__((used)) static void _logos_method$TWEAK$_UIStatusBarImageView$setVizView(_UIStatusBarImageView * __unused self, SEL __unused _cmd, VisualyzerView * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarImageView$vizView, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

static _UIStatusBarImageView* _logos_method$TWEAK$_UIStatusBarImageView$initWithFrame$(_LOGOS_SELF_TYPE_INIT _UIStatusBarImageView* __unused self, SEL __unused _cmd, CGRect frame) _LOGOS_RETURN_RETAINED {
    _UIStatusBarImageView *orig = _logos_orig$TWEAK$_UIStatusBarImageView$initWithFrame$(self, _cmd, frame);
    if (orig) {
        orig.vizView = [[VisualyzerView alloc] initWithFrame:frame]; 
    }
    return orig;
}

static void _logos_method$TWEAK$_UIStatusBarImageView$didMoveToWindow(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarImageView$didMoveToWindow(self, _cmd);
    if ([[_logos_static_class_lookup$SBMediaController() sharedInstance] isPlaying] && self.vizView.render) {
        self.vizView.hidden = NO;
    }else{
        self.vizView.hidden = YES;
    }
}

static void _logos_method$TWEAK$_UIStatusBarImageView$movedToSuperview$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIView * superview) {
    _logos_orig$TWEAK$_UIStatusBarImageView$movedToSuperview$(self, _cmd, superview);
    if (self.vizView) {
        [superview addSubview:self.vizView];
    }
}

static void _logos_method$TWEAK$_UIStatusBarImageView$removeFromSuperview(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if (self.vizView) {
        [self.vizView removeFromSuperview];
    }
    _logos_orig$TWEAK$_UIStatusBarImageView$removeFromSuperview(self, _cmd);
}

static void _logos_method$TWEAK$_UIStatusBarImageView$dealloc(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if (self.vizView) {
        self.vizView.parent = NULL;
        [self.vizView removeFromSuperview];
        self.vizView = NULL;
    }
    _logos_orig$TWEAK$_UIStatusBarImageView$dealloc(self, _cmd);
}





__attribute__((used)) static VisualyzerView * _logos_method$TWEAK$_UIStatusBarStringView$vizView(_UIStatusBarStringView * __unused self, SEL __unused _cmd) { return (VisualyzerView *)objc_getAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarStringView$vizView); }; __attribute__((used)) static void _logos_method$TWEAK$_UIStatusBarStringView$setVizView(_UIStatusBarStringView * __unused self, SEL __unused _cmd, VisualyzerView * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$TWEAK$_UIStatusBarStringView$vizView, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

static _UIStatusBarStringView* _logos_method$TWEAK$_UIStatusBarStringView$initWithFrame$(_LOGOS_SELF_TYPE_INIT _UIStatusBarStringView* __unused self, SEL __unused _cmd, CGRect frame) _LOGOS_RETURN_RETAINED {
    _UIStatusBarStringView *orig = _logos_orig$TWEAK$_UIStatusBarStringView$initWithFrame$(self, _cmd, frame);
    if (orig) {
        orig.vizView = [[VisualyzerView alloc] initWithFrame:frame];
        orig.vizView.parent = orig;
    }
    return orig;
}

static void _logos_method$TWEAK$_UIStatusBarStringView$didMoveToWindow(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    _logos_orig$TWEAK$_UIStatusBarStringView$didMoveToWindow(self, _cmd);
    if ([[_logos_static_class_lookup$SBMediaController() sharedInstance] isPlaying] && self.vizView.render) {
        self.hidden = YES;
        self.vizView.hidden = NO;
    }else{
        self.hidden = NO;
        self.vizView.hidden = YES;
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$movedToSuperview$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIView * superview) {
    _logos_orig$TWEAK$_UIStatusBarStringView$movedToSuperview$(self, _cmd, superview);
    if (self.vizView) {
        [superview addSubview:self.vizView];
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$setTextColor$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIColor * textColor) {
    _logos_orig$TWEAK$_UIStatusBarStringView$setTextColor$(self, _cmd, textColor);
    if (self.vizView) {
        self.vizView.pointColor = textColor;
        [self.vizView setFrame:self.frame];
    }
}

static void _logos_method$TWEAK$_UIStatusBarStringView$removeFromSuperview(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if (self.vizView) {
        [self.vizView removeFromSuperview];
    }
    _logos_orig$TWEAK$_UIStatusBarStringView$removeFromSuperview(self, _cmd);
}

static BOOL _logos_method$TWEAK$_UIStatusBarStringView$isHidden(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if ([[_logos_static_class_lookup$SBMediaController() sharedInstance] isPlaying] && self.vizView.render) {
        return YES;
    }
    return _logos_orig$TWEAK$_UIStatusBarStringView$isHidden(self, _cmd);
}

static void _logos_method$TWEAK$_UIStatusBarStringView$setHidden$(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, BOOL hidden) {
    if ([[_logos_static_class_lookup$SBMediaController() sharedInstance] isPlaying] && self.vizView.render) {
        return _logos_orig$TWEAK$_UIStatusBarStringView$setHidden$(self, _cmd, YES);
    }
    return _logos_orig$TWEAK$_UIStatusBarStringView$setHidden$(self, _cmd, hidden);
}

static void _logos_method$TWEAK$_UIStatusBarStringView$dealloc(_LOGOS_SELF_TYPE_NORMAL _UIStatusBarStringView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if (self.vizView) {
        self.vizView.parent = NULL;
        [self.vizView removeFromSuperview];
        self.vizView = NULL;
    }
    _logos_orig$TWEAK$_UIStatusBarStringView$dealloc(self, _cmd);
}





static __attribute__((constructor)) void _logosLocalCtor_1d0df149(int __unused argc, char __unused **argv, char __unused **envp) {
    {Class _logos_class$TWEAK$SBMediaController = objc_getClass("SBMediaController"); MSHookMessageEx(_logos_class$TWEAK$SBMediaController, @selector(_mediaRemoteNowPlayingApplicationIsPlayingDidChange:), (IMP)&_logos_method$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$, (IMP*)&_logos_orig$TWEAK$SBMediaController$_mediaRemoteNowPlayingApplicationIsPlayingDidChange$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'f'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$TWEAK$SBMediaController, @selector(volume), (IMP)&_logos_method$TWEAK$SBMediaController$volume, _typeEncoding); }Class _logos_class$TWEAK$SBBacklightController = objc_getClass("SBBacklightController"); MSHookMessageEx(_logos_class$TWEAK$SBBacklightController, @selector(setBacklightFactorPending:), (IMP)&_logos_method$TWEAK$SBBacklightController$setBacklightFactorPending$, (IMP*)&_logos_orig$TWEAK$SBBacklightController$setBacklightFactorPending$);Class _logos_class$TWEAK$_UIStatusBarDisplayItem = objc_getClass("_UIStatusBarDisplayItem"); MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(initWithIdentifier:item:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$initWithIdentifier$item$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$initWithIdentifier$item$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(dispatchVizContainerView), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$dispatchVizContainerView, _typeEncoding); }MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setContainerView:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setContainerView$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$setContainerView$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setLayoutItem:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setLayoutItem$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$setLayoutItem$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setAbsoluteFrame:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setAbsoluteFrame$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$setAbsoluteFrame$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setCenterOffset:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setCenterOffset$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$setCenterOffset$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setEnabled:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setEnabled$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$setEnabled$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(applyStyleAttributes:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$applyStyleAttributes$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$applyStyleAttributes$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setPlacement:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setPlacement$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$setPlacement$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setViewTransform:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setViewTransform$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$setViewTransform$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setBaselineOffset:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setBaselineOffset$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$setBaselineOffset$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setRegion:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setRegion$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarDisplayItem$setRegion$);{ char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(UIView *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(vizContainerView), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$vizContainerView, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(UIView *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarDisplayItem, @selector(setVizContainerView:), (IMP)&_logos_method$TWEAK$_UIStatusBarDisplayItem$setVizContainerView, _typeEncoding); } Class _logos_class$TWEAK$_UIStatusBarIndicatorAirplaneModeItem = objc_getClass("_UIStatusBarIndicatorAirplaneModeItem"); MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarIndicatorAirplaneModeItem, @selector(initWithIdentifier:statusBar:), (IMP)&_logos_method$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$initWithIdentifier$statusBar$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$initWithIdentifier$statusBar$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarIndicatorAirplaneModeItem, @selector(_create_imageView), (IMP)&_logos_method$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$_create_imageView, (IMP*)&_logos_orig$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$_create_imageView);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarIndicatorAirplaneModeItem, @selector(setImageView:), (IMP)&_logos_method$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$setImageView$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarIndicatorAirplaneModeItem$setImageView$);Class _logos_class$TWEAK$_UIStatusBarTimeItem = objc_getClass("_UIStatusBarTimeItem"); MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarTimeItem, @selector(initWithIdentifier:statusBar:), (IMP)&_logos_method$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarTimeItem$initWithIdentifier$statusBar$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarTimeItem, @selector(_create_shortTimeView), (IMP)&_logos_method$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView, (IMP*)&_logos_orig$TWEAK$_UIStatusBarTimeItem$_create_shortTimeView);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarTimeItem, @selector(setShortTimeView:), (IMP)&_logos_method$TWEAK$_UIStatusBarTimeItem$setShortTimeView$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarTimeItem$setShortTimeView$);Class _logos_class$TWEAK$_UIStatusBarCellularItem = objc_getClass("_UIStatusBarCellularItem"); MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarCellularItem, @selector(initWithIdentifier:statusBar:), (IMP)&_logos_method$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarCellularItem$initWithIdentifier$statusBar$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarCellularItem, @selector(_create_serviceNameView), (IMP)&_logos_method$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView, (IMP*)&_logos_orig$TWEAK$_UIStatusBarCellularItem$_create_serviceNameView);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarCellularItem, @selector(setServiceNameView:), (IMP)&_logos_method$TWEAK$_UIStatusBarCellularItem$setServiceNameView$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarCellularItem$setServiceNameView$);Class _logos_class$TWEAK$_UIStatusBarImageView = objc_getClass("_UIStatusBarImageView"); MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarImageView, @selector(initWithFrame:), (IMP)&_logos_method$TWEAK$_UIStatusBarImageView$initWithFrame$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarImageView$initWithFrame$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarImageView, @selector(didMoveToWindow), (IMP)&_logos_method$TWEAK$_UIStatusBarImageView$didMoveToWindow, (IMP*)&_logos_orig$TWEAK$_UIStatusBarImageView$didMoveToWindow);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarImageView, @selector(movedToSuperview:), (IMP)&_logos_method$TWEAK$_UIStatusBarImageView$movedToSuperview$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarImageView$movedToSuperview$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarImageView, @selector(removeFromSuperview), (IMP)&_logos_method$TWEAK$_UIStatusBarImageView$removeFromSuperview, (IMP*)&_logos_orig$TWEAK$_UIStatusBarImageView$removeFromSuperview);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarImageView, sel_registerName("dealloc"), (IMP)&_logos_method$TWEAK$_UIStatusBarImageView$dealloc, (IMP*)&_logos_orig$TWEAK$_UIStatusBarImageView$dealloc);{ char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(_UIStatusBarDisplayItem *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarImageView, @selector(displayItem), (IMP)&_logos_method$TWEAK$_UIStatusBarImageView$displayItem, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(_UIStatusBarDisplayItem *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarImageView, @selector(setDisplayItem:), (IMP)&_logos_method$TWEAK$_UIStatusBarImageView$setDisplayItem, _typeEncoding); } { char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(VisualyzerView *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarImageView, @selector(vizView), (IMP)&_logos_method$TWEAK$_UIStatusBarImageView$vizView, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(VisualyzerView *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarImageView, @selector(setVizView:), (IMP)&_logos_method$TWEAK$_UIStatusBarImageView$setVizView, _typeEncoding); } Class _logos_class$TWEAK$_UIStatusBarStringView = objc_getClass("_UIStatusBarStringView"); MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(initWithFrame:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$initWithFrame$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$initWithFrame$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(didMoveToWindow), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$didMoveToWindow, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$didMoveToWindow);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(movedToSuperview:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$movedToSuperview$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$movedToSuperview$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(setTextColor:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$setTextColor$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$setTextColor$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(removeFromSuperview), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$removeFromSuperview, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$removeFromSuperview);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(isHidden), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$isHidden, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$isHidden);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, @selector(setHidden:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$setHidden$, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$setHidden$);MSHookMessageEx(_logos_class$TWEAK$_UIStatusBarStringView, sel_registerName("dealloc"), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$dealloc, (IMP*)&_logos_orig$TWEAK$_UIStatusBarStringView$dealloc);{ char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(VisualyzerView *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarStringView, @selector(vizView), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$vizView, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(VisualyzerView *)); class_addMethod(_logos_class$TWEAK$_UIStatusBarStringView, @selector(setVizView:), (IMP)&_logos_method$TWEAK$_UIStatusBarStringView$setVizView, _typeEncoding); } }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        server();
    });
    
    MSHookFunction((void *)AudioUnitRender, (void *)&function_AudioUnitRender, (void **)&orig_AudioUnitRender);
}
