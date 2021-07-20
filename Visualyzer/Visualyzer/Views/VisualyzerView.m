#import "VisualyzerView.h"

#define pointSensitivity 1.0f
#define pointRadius 1.0f
#define pointSpacing 1.0f //halved
#define pointWidth 3.6f
#define pointMargin 5.0f

#define MIN_HZ 20
#define MAX_HZ 20000

@interface VisualyzerView ()
@end

@implementation VisualyzerView

+(NSUInteger)numberOfPointsForWidth:(CGFloat)width {
    CGFloat w = (width - pointMargin * 2.0f);
    CGFloat s = (pointSpacing + pointWidth + pointSpacing);
    NSUInteger p = floor(w / s);
    return p > 10 ? 10 : p;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.pointColor = [UIColor whiteColor];
        
        _bars = [NSMutableArray array];
        [self renderBarsInFrame:frame];

        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:singleFingerTap];
        
        _visible = [[NSClassFromString(@"SBBacklightController") sharedInstanceIfExists] screenIsOn];
        [[AudioManager sharedInstance] addObserver:self];
    }

	return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if (self.parent.shortTime) {
        SBApplication *nowPlayingApp = [[NSClassFromString(@"SBMediaController") sharedInstance] nowPlayingApplication];
        if(nowPlayingApp) {
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:nowPlayingApp.bundleIdentifier suspended:NO];
        }
    }
}

-(void)renderBarsInFrame:(CGRect)frame {
    if (self.parent.shortTime) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger n = _bars.count;
            NSUInteger points = [self.class numberOfPointsForWidth:frame.size.width];
            if (points > n) {
                for (NSUInteger i = 0; i < points - n; i++) {
                    CALayer *bar = [CALayer layer];
                    [self.layer addSublayer:bar];
                    [_bars addObject:bar];
                }
            }else if (points < n) {
                for (NSUInteger i = 0; i < n - points; i++) {
                    CALayer *bar = [_bars objectAtIndex:i];
                    [bar removeFromSuperlayer];
                    [_bars removeObject:bar];
                }
            }
            
            CGFloat x = pointMargin + (frame.size.width - pointMargin * 2.0f - (pointSpacing + pointWidth + pointSpacing) * points) / 2.0f;
            
            for (CALayer *bar in _bars) {
                bar.frame = CGRectMake(x + pointSpacing, frame.size.height, pointWidth, 0);
                bar.backgroundColor = self.pointColor.CGColor;
                bar.cornerRadius = pointRadius;
                x = x + pointSpacing + pointWidth + pointSpacing;
            }
        });
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
            for(NSUInteger i = 0; i < _bars.count; i++) {
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
    if (!CGRectEqualToRect(self.frame, self.parent.frame)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setFrame:self.parent.frame];
        });
        return;
    }
    /*
    NSUInteger n = _bars.count;
    CGFloat bin_len = MAX_HZ / n;
    CGFloat original_bin_len = MAX_HZ / length;
    NSMutableArray<NSNumber *> *bins = [NSMutableArray array];
    
    NSUInteger b = 0;
    for (NSUInteger i = 0; i < n; i++) {
        [bins addObject:@(0.0f)];
        while (b * original_bin_len <= bin_len * (i + 1)) {
            bins[i] = @([[bins objectAtIndex:i] floatValue] + data[b]);
            b += 1;
        }
        CALayer *bar = [_bars objectAtIndex:i];
        CGFloat heightMultiplier = [bins[i] floatValue] * pointSensitivity > 0.95 ? 0.95 : [bins[i] floatValue] * pointSensitivity;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            bar.backgroundColor = self.pointColor.CGColor;
            bar.frame = CGRectMake(bar.frame.origin.x, self.frame.size.height, bar.frame.size.width, -fabs(heightMultiplier * self.frame.size.height));
        });
    }
    */
    float octaves[10] = {0};
    float offset = 10.0f / _bars.count;
    float freq = 0;
    float binWidth = MAX_HZ / length;
    
    NSUInteger band = 0;
    float bandEnd = MIN_HZ * pow(2, 1);

    for(NSUInteger i = 0; i < length; i++) {
        freq = i > 0 ? i * binWidth : MIN_HZ;

        octaves[band] += data[i];

        if(freq > offset * bandEnd) {
            band += 1;
            bandEnd = MIN_HZ * pow(2, band + 1);
        }
    }
    
    for(NSUInteger i = 0; i < _bars.count; i++) {
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
