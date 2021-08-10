@class AudioManager;

@protocol AudioManagerDelegate<NSObject>
@required
-(void)mediaControllerStateChanged:(BOOL)state;
-(void)backlightLevelChanged:(CGFloat)level;
-(void)newAudioData:(float*)data withLength:(int)length sampleRate:(Float64)rate bitDepth:(UInt32)depth;
@end
