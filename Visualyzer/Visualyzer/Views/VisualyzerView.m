#import "VisualyzerView.h"

#define pointSensitivity 1.0f
#define pointRadius 1.0f
#define pointSpacing 2.0f
#define pointWidth 3.6f
#define pointNumber 4

#define MIN_HZ 20
#define MAX_HZ 20000

@interface VisualyzerView ()
@end

@implementation VisualyzerView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.pointColor = [UIColor whiteColor];
        
        _bars = [NSMutableArray array];
        for(NSUInteger i = 0; i < pointNumber; i++) {
            CALayer *bar = [CALayer layer];
            [self.layer addSublayer:bar];
            [_bars addObject:bar];
        }
        [self renderBarsInFrame:frame];

        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];

        UILongPressGestureRecognizer *holdFingerTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleHoldTap:)];
        [self addGestureRecognizer:holdFingerTap];
        
        _visible = [[NSClassFromString(@"SBBacklightController") sharedInstanceIfExists] screenIsOn];
        [[AudioManager sharedInstance] addObserver:self];
    }

	return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
	if (self.parent && self.parent.shortTime) {
        self.parent.alpha = 0.0;
        self.parent.hidden = NO;
		[UIView animateWithDuration:0.35 animations:^{
            self.alpha = 0.0;
            self.parent.alpha = 1.0;
        }completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.35 delay:2.0 options:UIViewAnimationOptionCurveLinear animations:^{
                    self.alpha = 1.0;
                    self.parent.alpha = 0.0;
                }completion:^(BOOL finished){
                    self.parent.hidden = YES;
                }];
            }
        }];
	}
}

- (void)handleHoldTap:(UITapGestureRecognizer *)recognizer {
    if (self.parent.shortTime) {
        SBApplication *nowPlayingApp = [[NSClassFromString(@"SBMediaController") sharedInstance] nowPlayingApplication];
        if(nowPlayingApp) {
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:nowPlayingApp.bundleIdentifier suspended:NO];
        }
    }
}

-(void)renderBarsInFrame:(CGRect)frame {
    if (self.parent.shortTime) {
        float leftOffset = (frame.size.width - (pointSpacing + pointWidth) * pointNumber - pointSpacing) / 2;

        for(NSUInteger i = 0; i < pointNumber; i++) {
            CALayer *bar = [_bars objectAtIndex:i];
            bar.frame = CGRectMake(leftOffset + i * (pointWidth + pointSpacing), frame.size.height, pointWidth, 0);
            bar.backgroundColor = self.pointColor.CGColor;
            bar.cornerRadius = pointRadius;
        }
    }
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self renderBarsInFrame:frame];
}

-(void)mediaControllerStateChanged:(BOOL)state {
    if (self.parent.shortTime) {
        if (state) {
            [self renderBarsInFrame:self.frame];
            [UIView animateWithDuration:0.35 animations:^{
                self.alpha = 1.0;
                self.parent.alpha = 0.0;
            }completion:^(BOOL finished) {
                self.hidden = NO;
                self.parent.hidden = YES;
            }];
        }else{
            [UIView animateWithDuration:0.35 animations:^{
                self.alpha = 0.0;
                self.parent.alpha = 1.0;
            }completion:^(BOOL finished) {
                self.hidden = YES;
                self.parent.hidden = NO;
            }];
            for(NSUInteger i = 0; i < pointNumber; i++) {
                CALayer *bar = [_bars objectAtIndex:i];
                dispatch_async(dispatch_get_main_queue(), ^{
                    bar.backgroundColor = self.pointColor.CGColor;
                    bar.frame = CGRectMake(bar.frame.origin.x, self.frame.size.height, bar.frame.size.width, 0);
                });
            }
        }
    }else{
        self.alpha = 0.0;
        self.parent.alpha = 1.0;
        self.hidden = YES;
        self.parent.hidden = NO;
    }
}

-(void)backlightLevelChanged:(CGFloat)level {
    _visible = level > 0.0f;
}

-(void)newAudioDataWasProcessed:(float *)data withLength:(int)length {
    if (!_visible || !self.parent.shortTime) return;
    
    float octaves[10] = {0};
    float offset = 10.0f / pointNumber;
    float freq = 0;
    float binWidth = MAX_HZ / length;
    
    int band = 0;
    float bandEnd = MIN_HZ * pow(2, 1);

    for(int i = 0; i < length; i++) {
        freq = i > 0 ? i * binWidth : MIN_HZ;

        octaves[band] += data[i];

        if(freq > offset * bandEnd) {
            band += 1;
            bandEnd = MIN_HZ * pow(2, band + 1);
        }
    }
    
    for(NSUInteger i = 0; i < pointNumber; i++) {
        CALayer *bar = [_bars objectAtIndex:i];
        CGFloat heightMultiplier = octaves[i] * pointSensitivity > 0.95 ? 0.95 : octaves[i] * pointSensitivity;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            bar.backgroundColor = self.pointColor.CGColor;
            bar.frame = CGRectMake(bar.frame.origin.x, self.frame.size.height, bar.frame.size.width, -fabs(heightMultiplier * self.frame.size.height));
        });
    }
}

-(void)dealloc {
    [[AudioManager sharedInstance] removeObserver:self];
}

@end
