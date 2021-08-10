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
        
        // Wait for anything to come from the client.
        rlen = recv(connfd, buffer, sizeof(buffer), 0);
        if (rlen <= 0) {
            if (rlen == 0) {
                close(connfd);
            }
            break;
        }

        // Send a dump of current audio buffer to the client.
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
    local.sin_addr.s_addr = htonl(INADDR_LOOPBACK); //INADDR_ANY if you want to expose audio output
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

%group TWEAK

%hook SBMediaController

-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerMediaNotification" object:@([self isPlaying])];
}

%new
-(float)volume {
    SBVolumeControl *control = MSHookIvar<SBVolumeControl *>(self, "_volumeControl");
    if (control) {
        return [control _effectiveVolume];
    }
    return 0.0f;
}

%end

%hook SBBacklightController

-(void)setBacklightFactorPending:(float)value {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightNotification" object:@(value)];
};

%end

%hook _UIStatusBarDisplayItem

%property (nonatomic, strong) UIView *vizContainerView;

-(id)initWithIdentifier:(id)arg1 item:(id)arg2 {
    _UIStatusBarDisplayItem *item = %orig;
    if (item) {
        [item dispatchVizContainerView];
    }
    return item;
}

%new
-(void)dispatchVizContainerView {
    if ([self item] && [[self item] isKindOfClass:%c(_UIStatusBarIndicatorAirplaneModeItem)]) {
        if (!self.vizContainerView) {
            self.vizContainerView = [[UIView alloc] init];
            self.vizContainerView.backgroundColor = [UIColor clearColor];
        }
        if ([self isEnabled] && [self visible] && ![[[self region] identifier] isEqualToString:@"trailing"]) {
            self.vizContainerView.hidden = NO;
            [[self containerView] addSubview:self.vizContainerView];
            //Supposing we are in this scenario:
            //<containerview><view></view><space></space></containerview>
            self.vizContainerView.frame = CGRectMake(self.view.frame.origin.x + self.view.frame.size.width, 0.0, self.containerView.frame.size.width - (self.view.frame.origin.x + self.view.frame.size.width), self.containerView.frame.size.height);
            
            ((_UIStatusBarImageView *)[self view]).displayItem = self;
            [[self containerView] addSubview:[((_UIStatusBarImageView *)[self view]) vizView]];
            [[((_UIStatusBarImageView *)[self view]) vizView] setParent:self.vizContainerView];
        }else{
            [((_UIStatusBarImageView *)[self view]) vizView].hidden = YES;
        }
    }
}

-(void)setContainerView:(UIView *)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

-(void)setLayoutItem:(id)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

-(void)setAbsoluteFrame:(CGRect)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

-(void)setCenterOffset:(double)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

-(void)setEnabled:(BOOL)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

-(void)applyStyleAttributes:(id)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

-(void)setPlacement:(id)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

-(void)setViewTransform:(CGAffineTransform)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

-(void)setBaselineOffset:(double)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

-(void)setRegion:(id)arg1 {
    %orig;
    [self dispatchVizContainerView];
}

%end

%hook _UIStatusBarIndicatorAirplaneModeItem

-(id)initWithIdentifier:(id)arg1 statusBar:(id)arg2 {
    _UIStatusBarIndicatorAirplaneModeItem *item = %orig;
    if (item) {
        [[[item imageView] vizView] setRender:YES];
    }
    return item;
}

-(void)_create_imageView {
    %orig;
    [[[self imageView] vizView] setRender:YES];
}

-(void)setImageView:(_UIStatusBarImageView *)arg1 {
    %orig;
    [[arg1 vizView] setRender:YES];
}

%end

%hook _UIStatusBarTimeItem

-(id)initWithIdentifier:(id)arg1 statusBar:(id)arg2 {
    _UIStatusBarTimeItem *orig = %orig;
    if (orig) {
        [[[orig shortTimeView] vizView] setRender:YES];
    }
    return orig;
}

-(void)_create_shortTimeView {
    %orig;
    [[[self shortTimeView] vizView] setRender:YES];
}

-(void)setShortTimeView:(_UIStatusBarStringView *)arg1 {
    [[arg1 vizView] setRender:YES];
}

%end

%hook _UIStatusBarCellularItem

-(id)initWithIdentifier:(id)arg1 statusBar:(id)arg2 {
    _UIStatusBarCellularItem *orig = %orig;
    if (orig) {
        [[[orig serviceNameView] vizView] setRender:YES];
    }
    return orig;
}

-(void)_create_serviceNameView {
    %orig;
    [[[self serviceNameView] vizView] setRender:YES];
}

-(void)setServiceNameView:(_UIStatusBarStringView *)arg1 {
    [[arg1 vizView] setRender:YES];
}

%end

%hook _UIStatusBarImageView

%property (nonatomic, strong) _UIStatusBarDisplayItem *displayItem;
%property (nonatomic, strong) VisualyzerView *vizView;

-(id)initWithFrame:(CGRect) frame {
    _UIStatusBarImageView *orig = %orig;
    if (orig) {
        orig.vizView = [[VisualyzerView alloc] initWithFrame:frame]; //TODO: better to not rely only in initWithFrame:
    }
    return orig;
}

-(void)didMoveToWindow {
    %orig;
    if ([[%c(SBMediaController) sharedInstance] isPlaying] && self.vizView.render) {
        self.vizView.hidden = NO;
    }else{
        self.vizView.hidden = YES;
    }
}

-(void)movedToSuperview:(UIView *)superview {
    %orig;
    if (self.vizView) {
        [superview addSubview:self.vizView];
    }
}

-(void)removeFromSuperview {
    if (self.vizView) {
        [self.vizView removeFromSuperview];
    }
    %orig;
}

-(void)dealloc {
    if (self.vizView) {
        self.vizView.parent = NULL;
        [self.vizView removeFromSuperview];
        self.vizView = NULL;
    }
    %orig;
}

%end

%hook _UIStatusBarStringView

%property (nonatomic, strong) VisualyzerView *vizView;

-(id)initWithFrame:(CGRect) frame {
    _UIStatusBarStringView *orig = %orig;
    if (orig) {
        orig.vizView = [[VisualyzerView alloc] initWithFrame:frame];
        orig.vizView.parent = orig;
    }
    return orig;
}

-(void)didMoveToWindow {
    %orig;
    if ([[%c(SBMediaController) sharedInstance] isPlaying] && self.vizView.render) {
        self.hidden = YES;
        self.vizView.hidden = NO;
    }else{
        self.hidden = NO;
        self.vizView.hidden = YES;
    }
}

-(void)movedToSuperview:(UIView *)superview {
    %orig;
    if (self.vizView) {
        [superview addSubview:self.vizView];
    }
}

-(void)setTextColor:(UIColor *)textColor {
    %orig;
    if (self.vizView) {
        self.vizView.pointColor = textColor;
        [self.vizView setFrame:self.frame];
    }
}

-(void)removeFromSuperview {
    if (self.vizView) {
        [self.vizView removeFromSuperview];
    }
    %orig;
}

-(BOOL)isHidden {
    if ([[%c(SBMediaController) sharedInstance] isPlaying] && self.vizView.render) {
        return YES;
    }
    return %orig;
}

-(void)setHidden:(BOOL)hidden {
    if ([[%c(SBMediaController) sharedInstance] isPlaying] && self.vizView.render) {
        return %orig(YES);
    }
    return %orig;
}

-(void)dealloc {
    if (self.vizView) {
        self.vizView.parent = NULL;
        [self.vizView removeFromSuperview];
        self.vizView = NULL;
    }
    %orig;
}

%end

%end

%ctor {
    %init(TWEAK);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        server();
    });
    
    MSHookFunction((void *)AudioUnitRender, (void *)&function_AudioUnitRender, (void **)&orig_AudioUnitRender);
}
