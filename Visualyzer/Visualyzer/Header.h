//
//  Header.h
//  Visualyzer
//
//  Created by gabriele filipponi on 19/07/21.
//

#ifndef Header_h
#define Header_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class VisualyzerView, _UIStatusBarDisplayItem;

@interface _UIStatusBarStringView : UIView
@property (nonatomic, strong) VisualyzerView *vizView;
-(void) setText:(id)arg1;
-(void)visualyzerStatusChanged:(NSNotification *)notification;
-(void)visualyzerBacklightChanged:(NSNotification *)notification;
-(void)changeVisualyzerColor:(NSNotification *)notification;
@end

@interface _UIStatusBarImageView : UIView
@property (nonatomic, strong) _UIStatusBarDisplayItem *displayItem;
@property (nonatomic, strong) VisualyzerView *vizView;
@end

@interface SBApplication : NSObject
@property (nonatomic, readonly) NSString * bundleIdentifier;
@end

@interface SBVolumeControl : NSObject
-(float)_effectiveVolume;
@end

@interface SBMediaController : NSObject
+(instancetype)sharedInstance;
-(SBApplication *)nowPlayingApplication;
-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 ;
-(BOOL)isPlaying;
-(float)volume;
@end

@interface UIApplication ()
-(BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2 ;
@end

@interface SBBacklightController : NSObject
@property (nonatomic,readonly) BOOL screenIsOn;
@property (nonatomic,readonly) BOOL screenIsDim;
@property (nonatomic,readonly) double backlightFactor;
+(id)sharedInstance;
+(id)sharedInstanceIfExists;
@end

@interface _UIStatusBarTimeItem : NSObject
@property (nonatomic,retain) _UIStatusBarStringView * timeView;
@property (nonatomic,retain) _UIStatusBarStringView * shortTimeView;
@property (nonatomic,retain) _UIStatusBarStringView * pillTimeView;
@property (nonatomic,retain) _UIStatusBarStringView * dateView;
+(id)shortTimeDisplayIdentifier;
+(id)timeDisplayIdentifier;
+(id)pillTimeDisplayIdentifier;
+(id)dateDisplayIdentifier;
-(_UIStatusBarStringView *)timeView;
-(_UIStatusBarStringView *)dateView;
-(_UIStatusBarStringView *)pillTimeView;
-(_UIStatusBarStringView *)shortTimeView;
@end

@interface _UIStatusBarCellularItem : NSObject
@property (nonatomic,retain) _UIStatusBarStringView * serviceNameView;
+(id)rawDisplayIdentifier;
+(id)signalStrengthDisplayIdentifier;
+(id)typeDisplayIdentifier;
+(id)nameDisplayIdentifier;
+(id)sosDisplayIdentifier;
+(id)warningDisplayIdentifier;
+(id)callForwardingDisplayIdentifier;
-(void)_create_serviceNameView;
-(void)setServiceNameView:(_UIStatusBarStringView *)arg1 ;
-(id)initWithIdentifier:(id)arg1 statusBar:(id)arg2 ;
-(_UIStatusBarStringView *)serviceNameView;
@end

@interface _UIStatusBarRegion : NSObject
-(NSString *)identifier;
@end

@interface _UIStatusBarDisplayItem : NSObject
@property (nonatomic, strong) UIView *vizContainerView;
-(id)initWithIdentifier:(id)arg1 item:(id)arg2;
-(id)item;
-(UIView *)view;
-(BOOL)visible;
-(UIView *)containerView;
-(void)setContainerView:(id)view;
-(void)dispatchVizContainerView;
-(BOOL)isEnabled;
-(id)layoutItem;
-(_UIStatusBarRegion *)region;
@end

@interface _UIStatusBarIndicatorAirplaneModeItem : NSObject
-(_UIStatusBarImageView *)imageView;
-(NSDictionary<NSString *, _UIStatusBarDisplayItem *>*)displayItems;
-(id)createDisplayItemForIdentifier:(id)identifier;
-(void)_applyUpdate:(id)data toDisplayItem:(id)item;
-(void)applyUpdate:(id)data toDisplayItem:(id)item;
-(void)updateDisplayItemsWithData:(id)data;
@end

@interface BluetoothManager : NSObject
+(id)sharedInstance;
-(NSArray *)connectedDevices;
@end

#endif /* Header_h */
