@class AudioManager;

@protocol AudioManagerDelegate<NSObject>
@required
-(void)mediaControllerStateChanged:(BOOL)state;
-(void)backlightLevelChanged:(CGFloat)level;
-(void)newAudioDataWasProcessed:(float*)data withLength:(int)length;
@end
