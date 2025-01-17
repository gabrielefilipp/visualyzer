#import "Tweak.h"


// Sends the notification when the phone start playing music
%hook SBMediaController
-(void)_mediaRemoteNowPlayingApplicationIsPlayingDidChange:(id)arg1 {
	%orig;

	if([self isPlaying])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerIsPlaying" object:nil];
	else
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerIsNotPlaying" object:nil];
}
%end


// Sends the notification when the phone's screen if OFF or ON
%hook SBBacklightController
-(void)setBacklightFactorPending:(float)value {
	%orig;

	// Screen is on
	if(value > 0.0f) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightIsOn" object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"visualyzerBacklightIsOff" object:nil];
	}
};
%end


/***********************************
 * CLOCK VIEW
************************************/

// When we want the visualyzer be in Clock location
%group ClockView
%hook _UIStatusBarStringView
%property(nonatomic) BOOL iAmTime;
%property(nonatomic) BOOL iAmCarrier;
%property(nonatomic, retain) VisualyzerView *vizView;

-(instancetype) initWithFrame:(CGRect) frame {
	id orig = %orig;
	self.iAmTime = NO; // :(
	self.iAmCarrier = NO;

	// Start/stop status
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startVisualyzer) name:@"visualyzerIsPlaying" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVisualyzer) name:@"visualyzerIsNotPlaying" object:nil];


	// Play/pause because of screen backlight
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeVisualyzer) name:@"visualyzerBacklightIsOn" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVisualyzer) name:@"visualyzerBacklightIsOff" object:nil];

	return orig;
}

-(void) setText:(NSString*)arg1 {
	%orig;
	if([arg1 containsString:@":"]){
		self.iAmTime = YES;
	} else if (prefHideCarrier && ![arg1 containsString:@"%"] && ![arg1 containsString:@"2G"] && ![arg1 containsString:@"3G"] && ![arg1 containsString:@"4G"] && ![arg1 containsString:@"5G"] && ![arg1 containsString:@"LTE"] && ![arg1 isEqualToString:@"E"]) {
		self.iAmCarrier = YES;
	}

}

-(void) setTextColor:(UIColor *)textColor {
	%orig;
	if(!self.iAmTime) return;

	if(self.vizView) self.vizView.pointColor = textColor;
}

%new
-(void) startVisualyzer {

	if(self.iAmTime) {

		// We can't create Bars at initWithFrame, because it doesn't have the same frame and bounds
		// So bars view would never appear
		if(!self.vizView) {
			self.vizView = [[BarsView alloc] initWithFrame:self.frame];

			// Settings
			self.vizView.pointNumber = [prefNumber intValue];
			self.vizView.pointWidth = [prefWidth floatValue];
			self.vizView.pointSpacing = [prefSpacing floatValue];
			self.vizView.pointRadius = [prefRadius floatValue];
			self.vizView.pointSensitivity = [prefSensitivity floatValue];
			self.vizView.pointAirpodsBoost = [prefAirpodsBoost floatValue];
			self.vizView.refreshRateInSeconds = (1.0f / [prefUpdatesPerSecond floatValue]);

			// Gestures
			self.vizView.isSingleTapEnabled = prefIsSingleTapEnabled;
			self.vizView.isLongTapEnabled = prefIsLongTapEnabled;

			self.vizView.parent = self;

			[self.superview addSubview:self.vizView];
			// [self.superview insertSubview:self.vizView atIndex:self.superview.subviews.count];
		}

		// Hide View
		[self setHidden:YES];

		// Show Visualyzer and start it
		[self.vizView setHidden:NO];
		[self.vizView start];

	} else if(self.iAmCarrier) {
		[self setHidden:YES];
	}

}

%new
-(void) stopVisualyzer {

	if(self.iAmTime) {
		[self setHidden:NO];
		[self.vizView setHidden:YES];

		[self.vizView stop];

	} else if(self.iAmCarrier) {
		[self setHidden:NO];
	}
}


// Probably I do need to delete this methods, because are almost pretty useless

// Used when the screen is now ON, and we want to resume
%new
-(void) resumeVisualyzer {
	if(!self.iAmTime) return;

	[self.vizView resume];
}


// Used when the screen is now OFF, and we want to pause
%new
-(void) pauseVisualyzer {
	if(!self.iAmTime) return;

	[self.vizView pause];
}

%end
%end


/***********************************
 * SIGNAL VIEW
************************************/

%group SignalView
%hook _UIStatusBarCellularSignalView

%property(nonatomic, retain) VisualyzerView *vizView;

-(id) initWithFrame:(CGRect)frame {

	id orig = %orig;
	NSLog(@"[Visualyzer] location: %@", location);

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startVisualyzer) name:@"visualyzerIsPlaying" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVisualyzer) name:@"visualyzerIsNotPlaying" object:nil];


	// Play/pause because of screen backlight
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeVisualyzer) name:@"visualyzerBacklightIsOn" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseVisualyzer) name:@"visualyzerBacklightIsOff" object:nil];

	return orig;
}

-(void)_colorsDidChange {
	%orig;

	if(self.vizView) {
		UIColor *color = [[UIColor alloc] initWithCGColor:self.layer.sublayers[0].backgroundColor];
		self.vizView.pointColor = color;
	}

}

%new
-(void) startVisualyzer {

	// We can't create Bars at initWithFrame, because it doesn't have the same frame and bounds
	// So bars view would never appear
	if(!self.vizView) {
		self.vizView = [[BarsView alloc] initWithFrame:self.frame];

		// Settings
		self.vizView.pointNumber = [prefNumber intValue];
		self.vizView.pointWidth = [prefWidth floatValue];
		self.vizView.pointSpacing = [prefSpacing floatValue];
		self.vizView.pointRadius = [prefRadius floatValue];
		self.vizView.pointSensitivity = [prefSensitivity floatValue];
		self.vizView.pointAirpodsBoost = [prefAirpodsBoost floatValue];
		self.vizView.refreshRateInSeconds = (1.0f / [prefUpdatesPerSecond floatValue]);

		// Gestures
		self.vizView.isSingleTapEnabled = prefIsSingleTapEnabled;
		self.vizView.isLongTapEnabled = prefIsLongTapEnabled;

		self.vizView.parent = self;

		[self.superview addSubview:self.vizView];
		// [self.superview insertSubview:self.vizView atIndex:self.superview.subviews.count];
	}

	// Hide View
	[self setHidden:YES];

	// Show Visualyzer and start it
	[self.vizView setHidden:NO];
	[self.vizView start];

}

%new
-(void) stopVisualyzer {

	[self setHidden:NO];
	[self.vizView setHidden:YES];

	[self.vizView stop];
}


// Probably I do need to delete this methods, because are almost pretty useless

// Used when the screen is now ON, and we want to resume
%new
-(void) resumeVisualyzer {
	[self.vizView resume];
}


// Used when the screen is now OFF, and we want to pause
%new
-(void) pauseVisualyzer {
	[self.vizView pause];
}

%end
%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"com.xyaman.visualyzerpreferences"];
	
	[preferences registerBool:&isEnabled default:NO forKey:@"isEnabled"];
	if(!isEnabled) return;

	// Load all preferences
	[preferences registerObject:&prefNumber default:@"4" forKey:@"number"]; // Number of bars/points/etc
	[preferences registerObject:&prefWidth default:@"3.6" forKey:@"width"]; // Width of ...
	[preferences registerObject:&prefSpacing default:@"2.0" forKey:@"spacing"];
	[preferences registerObject:&prefRadius default:@"1.0" forKey:@"radius"];
	[preferences registerObject:&prefSensitivity default:@"1.0" forKey:@"sensitivity"];
	[preferences registerObject:&prefAirpodsBoost default:@"1.0" forKey:@"airpodsBoost"];
	[preferences registerObject:&prefUpdatesPerSecond default:@"10.0" forKey:@"updatesPerSecond"];

	[preferences registerBool:&prefHideCarrier default:NO forKey:@"hideCarrier"];

	// Gestures
	[preferences registerBool:&prefIsSingleTapEnabled default:YES forKey:@"isSingleTapEnabled"];
	[preferences registerBool:&prefIsLongTapEnabled default:YES forKey:@"isLongTapEnabled"];

	// Location
	[preferences registerObject:&location default:@"1" forKey:@"location"];

	%init;
	if([location intValue] == clockLocation){
		%init(ClockView);	
	} else if ([location intValue] == signalLocation) {
		%init(SignalView);
	}
}