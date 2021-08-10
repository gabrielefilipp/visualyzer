#import "VisualyzerView.h"

#define pointRadius 1.0f
#define pointSpacing 0.8f //halved, cause it (*|*)(*|*), where "*" is the spacing and "|" is bar
#define pointWidth 3.0f
#define pointMargin 5.0f

#define sensitivity 0.95f
#define gain 50.0f

#define MIN_HZ 20

@interface VisualyzerView ()
@end

@implementation VisualyzerView

+(NSUInteger)numberOfPointsForWidth:(CGFloat)width {
    CGFloat w = (width - pointMargin * 2.0f);
    CGFloat s = (pointSpacing + pointWidth + pointSpacing);
    return fmin(floor(w / s), 10);
    //return floor(w / s);
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _render = NO;
        
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
    if (_render) {
        SBApplication *nowPlayingApp = [[NSClassFromString(@"SBMediaController") sharedInstance] nowPlayingApplication];
        if(nowPlayingApp) {
            [[UIApplication sharedApplication] launchApplicationWithIdentifier:nowPlayingApp.bundleIdentifier suspended:NO];
        }
    }
}

-(void)renderBarsInFrame:(CGRect)frame {
    if (_render) {
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
                CALayer *bar = [_bars objectAtIndex:0];
                [bar removeFromSuperlayer];
                [_bars removeObject:bar];
            }
        }
        
        CGFloat x = pointMargin + (frame.size.width - pointMargin * 2.0f - (pointSpacing + pointWidth + pointSpacing) * points) / 2.0f;
        
        for (CALayer *bar in _bars) {
            bar.frame = CGRectMake(x + pointSpacing, frame.size.height, pointWidth, 0.0f);
            bar.backgroundColor = self.pointColor.CGColor;
            bar.cornerRadius = pointRadius;
            x = x + pointSpacing + pointWidth + pointSpacing;
        }
    }
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self renderBarsInFrame:frame];
}

-(void)mediaControllerStateChanged:(BOOL)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_render) {
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
    });
}

-(void)backlightLevelChanged:(CGFloat)level {
    _visible = level > 0.0f;
}

-(void)newAudioData:(float *)data withLength:(int)length sampleRate:(Float64)rate bitDepth:(UInt32)depth {
    rate /= 2.0f; //For Nyquist
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_visible || !_render || self.hidden) return;
        if (!CGRectEqualToRect(self.frame, self.parent.frame)) {
            [self setFrame:self.parent.frame];
            return;
        }
        
        float volume = [((SBMediaController *)[NSClassFromString(@"SBMediaController") sharedInstance]) volume];
        float scale = fmin(sqrt(1 - pow(volume - 1, 2)), 1.0f);
        
        NSUInteger n = _bars.count;
        
        if (n == 0) return;
        
        //float bin_len = rate / (float)n;
        float original_bin_len = rate / (float)length;
        float bins[10] = { 0.0f };
        
        float base = pow(rate / MIN_HZ, 1.0f / (float)n);
        
        int b = 0;
        for (int i = 0; i < n; i++) {
            //while (b * original_bin_len <= (i + 1) * bin_len) {
            while (b * original_bin_len <= MIN_HZ * pow(base, i + 1)) {
                bins[i] += data[b];
                b += 1;
            }
            CALayer *bar = [_bars objectAtIndex:i];
            CGFloat heightMultiplier = fmin(fmax(bins[i] * scale, 0.0f), scale);
            
            bar.backgroundColor = self.pointColor.CGColor;
         if (!isnan(self.frame.size.height) && !isnan(heightMultiplier)) {
             bar.frame = CGRectMake(bar.frame.origin.x, self.frame.size.height, bar.frame.size.width, -fabs(heightMultiplier * self.frame.size.height));
         }else{
             bar.frame = CGRectMake(bar.frame.origin.x, self.frame.size.height, bar.frame.size.width, 0.0f);
         }
        }
    });
    
        /*
        float octaves[10] = { 0.0f };
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
            bar.backgroundColor = self.pointColor.CGColor;
            if (!isnan(self.frame.size.height) && !isnan(heightMultiplier)) {
                bar.frame = CGRectMake(bar.frame.origin.x, self.frame.size.height, bar.frame.size.width, -fabs(heightMultiplier * self.frame.size.height));
            }
        }
    });
         */
}

-(void)dealloc {
    [[AudioManager sharedInstance] removeObserver:self];
}

@end
