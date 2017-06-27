//
//  Orientation.m
//

#import "Orientation.h"
#if __has_include(<React/RCTEventDispatcher.h>)
#import <React/RCTEventDispatcher.h>
#else
#import "RCTEventDispatcher.h"
#endif

@implementation Orientation
@synthesize bridge = _bridge;

static UIInterfaceOrientationMask _orientation = UIInterfaceOrientationMaskAllButUpsideDown;
+ (void)setOrientation: (UIInterfaceOrientationMask)orientation {
    _orientation = orientation;
}
+ (UIInterfaceOrientationMask)getOrientation {
    return _orientation;
}

- (instancetype)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    return self;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"specificOrientationDidChange"
                                                    body:@{@"specificOrientation": [self getSpecificOrientationStr:orientation]}];
    
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"orientationDidChange"
                                                    body:@{@"orientation": [self getOrientationStr:orientation]}];
    
}

- (NSString *)getOrientationStr: (UIDeviceOrientation)orientation {
    NSString *orientationStr;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationStr = @"PORTRAIT";
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            
            orientationStr = @"LANDSCAPE";
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orientationStr = @"PORTRAITUPSIDEDOWN";
            break;
            
        default:
            orientationStr = @"UNKNOWN";
            break;
    }
    return orientationStr;
}

- (NSString *)getSpecificOrientationStr: (UIDeviceOrientation)orientation {
    NSString *orientationStr;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            orientationStr = @"PORTRAIT";
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            orientationStr = @"LANDSCAPE-LEFT";
            break;
            
        case UIDeviceOrientationLandscapeRight:
            orientationStr = @"LANDSCAPE-RIGHT";
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            orientationStr = @"PORTRAITUPSIDEDOWN";
            break;
            
        default:
            orientationStr = @"UNKNOWN";
            break;
    }
    return orientationStr;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getOrientation:(RCTResponseSenderBlock)callback)
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *orientationStr = [self getOrientationStr:orientation];
    callback(@[[NSNull null], orientationStr]);
}

RCT_EXPORT_METHOD(getSpecificOrientation:(RCTResponseSenderBlock)callback)
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *orientationStr = [self getSpecificOrientationStr:orientation];
    callback(@[[NSNull null], orientationStr]);
}

RCT_EXPORT_METHOD(lockToPortrait)
{
#if DEBUG
    NSLog(@"Locked to Portrait");
#endif
    [Orientation setOrientation:UIInterfaceOrientationMaskPortrait];
    [self changeOrientation:UIInterfaceOrientationPortrait];
}

RCT_EXPORT_METHOD(lockToLandscape)
{
#if DEBUG
    NSLog(@"Locked to Landscape");
#endif
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *orientationStr = [self getSpecificOrientationStr:orientation];
    if ([orientationStr isEqualToString:@"LANDSCAPE-LEFT"]) {
        [Orientation setOrientation:UIInterfaceOrientationMaskLandscape];
        [self changeOrientation:UIInterfaceOrientationLandscapeRight];
    } else {
        [Orientation setOrientation:UIInterfaceOrientationMaskLandscape];
        [self changeOrientation:UIInterfaceOrientationLandscapeLeft];
    }
}

RCT_EXPORT_METHOD(lockToLandscapeLeft)
{
#if DEBUG
    NSLog(@"Locked to Landscape Left");
#endif
    [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
    [self changeOrientation:UIInterfaceOrientationLandscapeLeft];
}

RCT_EXPORT_METHOD(lockToLandscapeRight)
{
#if DEBUG
    NSLog(@"Locked to Landscape Right");
#endif
    [Orientation setOrientation:UIInterfaceOrientationMaskLandscapeRight];
    [self changeOrientation:UIInterfaceOrientationLandscapeRight];
}

RCT_EXPORT_METHOD(unlockAllOrientations)
{
#if DEBUG
    NSLog(@"Unlock All Orientations");
#endif
    [Orientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
    //  AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //  delegate.orientation = 3;
}

- (void)changeOrientation:(UIInterfaceOrientation)orientation{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIInterfaceOrientationUnknown] forKey:@"orientation"];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: orientation] forKey:@"orientation"];
    }];
}

- (NSDictionary *)constantsToExport
{
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    NSString *orientationStr = [self getOrientationStr:orientation];
    
    return @{
             @"initialOrientation": orientationStr
             };
}

@end
