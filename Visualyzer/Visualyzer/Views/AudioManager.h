#import <UIKit/UIKit.h>
#import <Accelerate/Accelerate.h>
#import <arpa/inet.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AudioManagerDelegate.h"

#define SA struct sockaddr
#define ASSPORT 44333
#define MAX_BUFFER_SIZE 16384
#define FFT_LENGTH 1024
#define FFT_AIRPODS_LENGTH 256


@interface AudioManager : NSObject {
	// Socket related
	struct sockaddr_in _addr;
	BOOL _isConnected;

	// Audio relate
	struct vDSP_DFT_SetupStruct *_fftSetup;
	struct vDSP_DFT_SetupStruct *_fftAirpodsSetup; // Airpods

	struct DSPSplitComplex _complex;
    float *_realIn;
    float *_imagIn;
    float *_realOut;
    float *_imagOut;
    float *_magnitudes;
    float _scalingFactor;
    
    NSMutableArray <id<AudioManagerDelegate>> *_observers;
}
+(instancetype)sharedInstance;
-(void)addObserver:(id<AudioManagerDelegate>)observer;
-(void)removeObserver:(id<AudioManagerDelegate>)observer;
@end
