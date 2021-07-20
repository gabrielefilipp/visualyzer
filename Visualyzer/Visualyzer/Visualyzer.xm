#import "Header.h"
#import "Views/VisualyzerView.h"

%group TWEAK

%hook SBMediaController

-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerMediaNotification" object:@([self isPlaying])];
}

%end

%hook SBBacklightController

-(void)setBacklightFactorPending:(float)value {
    %orig;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightNotification" object:@(value)];
};

%end

%hook _UIStatusBarTimeItem

-(id)initWithIdentifier:(id)arg1 statusBar:(id)arg2 {
    _UIStatusBarTimeItem *orig = %orig;
    if (orig) {
        [[orig shortTimeView] setShortTime:YES];
    }
    return orig;
}

-(void)_create_shortTimeView {
    %orig;
    [[self shortTimeView] setShortTime:YES];
}

-(void)setShortTimeView:(_UIStatusBarStringView *)arg1 {
    [arg1 setShortTime:YES];
}

%end

%hook _UIStatusBarCellularItem

-(id)initWithIdentifier:(id)arg1 statusBar:(id)arg2 {
    _UIStatusBarCellularItem *orig = %orig;
    if (orig) {
        [[orig serviceNameView] setShortTime:YES];
    }
    return orig;
}

-(void)_create_serviceNameView {
    %orig;
    [[self serviceNameView] setShortTime:YES];
}

-(void)setServiceNameView:(_UIStatusBarStringView *)arg1 {
    [arg1 setShortTime:YES];
}

%end

%hook _UIStatusBarStringView

%property (nonatomic, strong) VisualyzerView *vizView;
%property (nonatomic, assign) BOOL shortTime;

-(id)initWithFrame:(CGRect) frame {
    _UIStatusBarStringView *orig = %orig;
    if (orig) {
        orig.shortTime = NO;
        orig.vizView = [[VisualyzerView alloc] initWithFrame:frame];
        orig.vizView.parent = orig;
    }
    return orig;
}

-(void)didMoveToWindow {
    %orig;
    if ([[%c(SBMediaController) sharedInstance] isPlaying] && self.shortTime) {
        self.hidden = YES;
        self.vizView.hidden = NO;
        [self.vizView setFrame:self.frame];
    }else{
        self.hidden = NO;
        self.vizView.hidden = YES;
    }
}

-(void)movedToSuperview:(UIView *)superview {
    %orig;
    if (self.vizView) {
        [self.vizView setFrame:self.frame];
        [superview addSubview:self.vizView];
    }
}

-(void)layoutSubviews {
    %orig;
    if (self.vizView) {
        [self.vizView setFrame:self.frame];
    }
}

-(void)setFrame:(CGRect)frame {
    %orig;
    if (self.vizView) {
        [self.vizView setFrame:self.frame];
    }
}

-(void)removeFromSuperview {
    %orig;
    if (self.vizView) {
        [self.vizView removeFromSuperview];
    }
}

-(void)setText:(NSString*)arg1 {
    %orig;
    if (self.vizView) {
        [self.vizView setFrame:self.frame];
    }
}

-(void)setTextColor:(UIColor *)textColor {
    %orig;
    if (self.vizView) {
        self.vizView.pointColor = textColor;
        [self.vizView setFrame:self.frame];
    }
}

-(void)dealloc {
    if (self.vizView) {
        self.vizView.parent = NULL;
        [self.vizView removeFromSuperview];
        self.vizView = NULL;
    }
    %orig;
}

-(BOOL)isHidden {
    if ([[%c(SBMediaController) sharedInstance] isPlaying] && self.shortTime) {
        return YES;
    }
    return %orig;
}

-(void)setHidden:(BOOL)hidden {
    if ([[%c(SBMediaController) sharedInstance] isPlaying] && self.shortTime) {
        return %orig(YES);
    }
    return %orig;
}

%end

%end

%ctor {
    %init(TWEAK);
}
