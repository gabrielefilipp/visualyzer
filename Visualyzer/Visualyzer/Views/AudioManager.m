#import <spawn.h>

#import "AudioManager.h"
#import "Header.h"

static OSStatus renderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp * inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList * __nullable ioData) {
    return kAudioServicesNoError;
}

@implementation AudioManager
/*
-(OSStatus)callbackWithRefCon:(void *)inRefCon flags:(AudioUnitRenderActionFlags *)ioActionFlags timestamp:(const AudioTimeStamp *)inTimeStamp bus:(UInt32)inBusNumber frames:(UInt32)inNumberFrames data:(AudioBufferList * __nullable)ioData {
    
}
*/
+(instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static AudioManager *_sharedObject = nil;
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(instancetype) init {
    if (self = [super init]) {
        _observers = [NSMutableArray array];
        
        // Socket initialization related
        _isConnected = NO;
        
        // Host addr
        _addr.sin_family = AF_INET;
        _addr.sin_port = htons(ASSPORT);
        _addr.sin_addr.s_addr = inet_addr("127.0.0.1");

        // Audio processing related
        _fftSetup = vDSP_DFT_zop_CreateSetup(NULL, FFT_LENGTH, vDSP_DFT_FORWARD);
        _fftAirpodsSetup = vDSP_DFT_zop_CreateSetup(NULL, FFT_AIRPODS_LENGTH, vDSP_DFT_FORWARD);

        _realIn = (float *)calloc(FFT_LENGTH, sizeof(float));
        _imagIn = (float *)calloc(FFT_LENGTH, sizeof(float));
        _realOut = (float *)calloc(FFT_LENGTH, sizeof(float));
        _imagOut = (float *)calloc(FFT_LENGTH, sizeof(float));
        _window = (float *)calloc(FFT_LENGTH, sizeof(float));
        _scalingFactor = (2.0f / FFT_LENGTH);
        
        vDSP_hann_window(_window, FFT_LENGTH, vDSP_HANN_NORM);

        _magnitudes = (float *)calloc(FFT_LENGTH / 2.0f, sizeof(float));

        _complex.realp = _realOut;
        _complex.imagp = _imagOut;
        
        _lock = [[NSLock alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visualyzerStatusChanged:) name:@"visualyzerMediaNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(visualyzerBacklightChanged:) name:@"visualyzerBacklightNotification" object:nil];
    }
    return self;
}

-(void)threadSafeOperation:(void (^)(void))operation {
    [_lock lock];
    operation();
    [_lock unlock];
}

-(void)visualyzerStatusChanged:(NSNotification *)notification {
    if ([notification.object boolValue]) {
        [self startConnection];
    }else{
        [self stopConnection];
    }
}

-(void)visualyzerBacklightChanged:(NSNotification *)notification {
    [self threadSafeOperation:^{
        for (NSUInteger i = 0; i < [_observers count]; i++) {
            [[_observers objectAtIndex:i] backlightLevelChanged:[notification.object floatValue]];
        }
    }];
}

-(void)addObserver:(id<AudioManagerDelegate>)observer {
    [self threadSafeOperation:^{
        if (![_observers containsObject:observer]) {
            [_observers addObject:observer];
        }
    }];
}

-(void)removeObserver:(id<AudioManagerDelegate>)observer {
    [self threadSafeOperation:^{
        [_observers removeObject:observer];
    }];
}

/**
 Author NepetaDev, https://github.com/NepetaDev/MitsuhaInfinity/blob/master/ASSWatchdog/Tweak.xm
*/
-(int)testAndSetupConnection {
    const int one = 1;
    int connfd;
    struct sockaddr_in remote;
    remote.sin_family = PF_INET;
    remote.sin_port = htons(ASSPORT);
    inet_aton("127.0.0.1", &remote.sin_addr);
    int r = -1;
    int retries = 0;

    while (connfd != -2) {
        retries++;
        connfd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);

        if (connfd == -1) {
            usleep(1000 * 1000);
            continue;
        }
        setsockopt(connfd, SOL_SOCKET, SO_NOSIGPIPE, &one, sizeof(one));

        while(r != 0) {
            if (retries > 3) {
                connfd = -2;
                pid_t pid;
                const char* args[] = {"killall", "mediaserverd", NULL};
                posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
                break;
            }

            r = connect(connfd, (struct sockaddr *)&remote, sizeof(remote));
            usleep(200 * 1000);
            retries++;
        }

        if (connfd > 0) {
            return connfd;
        }
        
        return -1;
    }
    return -1;
}

- (void)startConnection {
    if(_isConnected) return;
    _isConnected = YES;
    
    [self threadSafeOperation:^{
        for (NSUInteger i = 0; i < [_observers count]; i++) {
            [[_observers objectAtIndex:i] mediaControllerStateChanged:YES];
        }
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int sockfd = -1;
        while(_isConnected) {
            // Create socket
            sockfd = [self testAndSetupConnection];
            if (sockfd == -1) {
                usleep(1000 * 1000);
                continue;
            }

            // Buffer related
            int hello = 1;
            float dummyData[4]; // Sometimes socket receives a float
            UInt32 bufferSize = 0;
            int bufferLength = 0; // bufferSize / sizeof(float)
            float buffer[MAX_BUFFER_SIZE];
            
            Float64 rate = 0;
            UInt32 depth = 0;

            while(_isConnected) {
                // Send initial message.
                ssize_t wlen = write(sockfd, &hello, sizeof(hello));
                if(wlen < 0) { // We've lost the connection
                    close(sockfd);
                    break;
                }

                // Response -> data bufferSize with size of UInt32.
                ssize_t rlen = read(sockfd, &bufferSize, sizeof(bufferSize));
                if(rlen < 0) { // We've lost the connection
                    close(sockfd);
                    break;
                }

                // This shouldn't happens but sometimes happens
                if(bufferSize > MAX_BUFFER_SIZE || bufferSize < sizeof(float)) {
                    close(sockfd);
                    break;
                }


                // When no data is available, the host sends ONE float.
                if(bufferSize == sizeof(float)) {
                    rlen = read(sockfd, dummyData, bufferSize);
                    if (rlen < 0) {
                        close(sockfd);
                        break;
                    }
                    //if (dummyData[0] == 0.0f) continue;
                    continue;
                }

                // If we are still here, it means now we have REAL data audio :)
                rlen = read(sockfd, buffer, bufferSize);
                if(rlen < 0) {
                    close(sockfd);
                    break;
                }
                
                rlen = read(sockfd, &rate, sizeof(rate));
                if(rlen < 0) {
                    close(sockfd);
                    break;
                }
                
                rlen = read(sockfd, &depth, sizeof(depth));
                if(rlen < 0) {
                    close(sockfd);
                    break;
                }
                
                bufferLength = bufferSize / sizeof(float);

                // Now we process the audio data

                // we need length, because when using Airpods, the length is 256
                int length = [self processRawAudio:buffer withLength:bufferLength sampleRate:rate bitDepth:depth];
                
                [self threadSafeOperation:^{
                    // Now we send to our delegate :D
                    for (NSUInteger i = 0; i < [_observers count]; i++) {
                        [[_observers objectAtIndex:i] newAudioData:_magnitudes withLength:length sampleRate:rate bitDepth:depth];
                    }
                }];

                // Zzz
                usleep(0.1f * 1000000);
            }
        }
        // Close the socket
        close(sockfd);
    });
}

-(void)stopConnection {
    _isConnected = NO;
    
    for (NSUInteger i = 0; i < [_observers count]; i++) {
        [[_observers objectAtIndex:i] mediaControllerStateChanged:NO];
    }
}

- (int)processRawAudio:(float*)buffer withLength:(int)bufferLength sampleRate:(Float64)rate bitDepth:(UInt32)depth {
    _peppa = bufferLength;
    
    // Special case, only happens when we're using Airpods
    vDSP_vmul(buffer, 1, _window, 1, buffer, 1, FFT_LENGTH);
    
    if(bufferLength == 480) {
        return [self processAirpodsAudio:buffer sampleRate:rate bitDepth:depth];
    }

    // First, we compress the audio, only if bigger than our fft length
    // No effect if compression rate is 1
    int compressionRate = bufferLength / FFT_LENGTH;

    // Copy the buffer to our allocated array
    for(int i = 0; i < FFT_LENGTH; i++) {
        _realIn[i] = buffer[i * compressionRate];
    }
    
    // Execute our Discrete Fourier Transformation to get the audio frequency
    vDSP_DFT_Execute(_fftSetup, _realIn, _imagIn, _realOut, _imagOut);

    // Calculate the absolute value of the complex number
    // Remember: complex.realp = _realOut, complex.imagp = _imagOut
    // Here we get data / 2;
    vDSP_zvabs(&_complex, 1, _magnitudes, 1, FFT_LENGTH / 2);

    // Now we normalize the magnitudes a little
    vDSP_vsmul(_magnitudes, 1, &_scalingFactor, _magnitudes, 1, FFT_LENGTH / 2);

    return FFT_LENGTH / 2;
}

- (int)processAirpodsAudio:(float*)buffer sampleRate:(Float64)rate bitDepth:(UInt32)depth {

    // Just for now
    float scale = 1.0f;
    
    // We can only use a pow of 2, length is 480
    // so we will use 256 frames

    // Copy the buffer to our allocated array
    for(int i = 0; i < 256; i++) {
        _realIn[i] = buffer[i];
    }

    // Execute our Discrete Fourier Transformation to get the audio frequency
    vDSP_DFT_Execute(_fftAirpodsSetup, _realIn, _imagIn, _realOut, _imagOut);

    // Calculate the absolute value of the complex number
    // Remember: complex.realp = _realOut, complex.imagp = _imagOut
    // Here we get data / 2;
    vDSP_zvabs(&_complex, 1, _magnitudes, 1, FFT_AIRPODS_LENGTH / 2);

    // Now we normalize the magnitudes a little
    vDSP_vsmul(_magnitudes, 1, &scale, _magnitudes, 1, FFT_AIRPODS_LENGTH / 2);

    return FFT_AIRPODS_LENGTH / 2;
}

-(void)dealloc {
    _isConnected = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"visualyzerMediaNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"visualyzerBacklightNotification" object:nil];
    
    vDSP_DFT_DestroySetup(_fftSetup);
    vDSP_DFT_DestroySetup(_fftAirpodsSetup);

    free(_realIn);
    free(_imagIn);
    free(_realOut);
    free(_imagOut);
    free(_magnitudes);
    free(_window);
}

@end

