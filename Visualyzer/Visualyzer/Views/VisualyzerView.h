#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "AudioManager.h"

#import "Header.h"

@interface VisualyzerView: UIView <AudioManagerDelegate> {
    BOOL _visible;
}
@property (nonatomic, assign) BOOL render;
@property (nonatomic, strong) UIView *parent;
@property (nonatomic, strong) UIColor *pointColor;
@property (nonatomic, strong, readonly) NSMutableArray<CALayer*> *bars;
-(void)handleSingleTap:(UITapGestureRecognizer *)recognizer;
@end
