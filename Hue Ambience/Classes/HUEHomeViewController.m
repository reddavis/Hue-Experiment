//
//  HUEHomeViewController.m
//  Hue Ambience
//
//  Created by Red Davis on 02/01/2014.
//  Copyright (c) 2014 Red Davis. All rights reserved.
//

#import "HUEHomeViewController.h"
#import "HUEAverageColorCalculator.h"

#import <AVFoundation/AVFoundation.h>
#import <HueSDK/HueSDK.h>


@interface HUEHomeViewController ()

@property (strong, nonatomic) PHHueSDK *hueSDK;
@property (assign, nonatomic) BOOL canChangeLights;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (strong, nonatomic) UIView *captureOutputView;
@property (strong, nonatomic) UIImageView *capturedImageView;
@property (strong, nonatomic) UIView *averageColorView;

@property (strong, nonatomic) NSTimer *captureTimer;

@property (strong, nonatomic) HUEAverageColorCalculator *averageColorCalculator;

- (void)captureImage;

- (void)startHeartBeat;
- (void)stopHeartBeat;

- (void)localConnectionNotification;
- (void)authenticationSuccessNotification;
- (void)noLocalAuthenticationNotification;
- (void)noLocalConnectionNotification;

@end


static NSString *const HUEBridgeIPAddress = nil;
static NSString *const HUEBridgeMACAddress = nil;

static CGFloat const HUEImageCaptureFramesPerSecond = 20.0; // TODO: Experiment with FPS


@implementation HUEHomeViewController

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
		self.title = NSLocalizedString(@"Home", @"Home");
		
		self.averageColorCalculator = [[HUEAverageColorCalculator alloc] init];
		
		PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
		[notificationManager registerObject:self withSelector:@selector(localConnectionNotification) forNotification:LOCAL_CONNECTION_NOTIFICATION];
		[notificationManager registerObject:self withSelector:@selector(noLocalConnectionNotification) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
		[notificationManager registerObject:self withSelector:@selector(noLocalAuthenticationNotification) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
		[notificationManager registerObject:self withSelector:@selector(authenticationSuccessNotification) forNotification:PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION];
    }
	
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSAssert(HUEBridgeIPAddress, @"You haven't set your Hue IP address");
	NSAssert(HUEBridgeMACAddress, @"You haven't set your Hue MAC address");
	
	self.capturedImageView = [[UIImageView alloc] init];
	[self.view addSubview:self.capturedImageView];
	
	self.averageColorView = [[UIView alloc] init];
	self.averageColorView.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:self.averageColorView];
	
	// Hue
	self.hueSDK = [[PHHueSDK alloc] init];
	[self.hueSDK startUpSDK];
	[self.hueSDK enableLogging:NO];
	
	[self.hueSDK setBridgeToUseWithIpAddress:HUEBridgeIPAddress macAddress:HUEBridgeMACAddress andUsername:[PHUtilities whitelistIdentifier]];
	[self performSelector:@selector(startHeartBeat) withObject:self afterDelay:1];
	
	// Video
	self.captureSession = [[AVCaptureSession alloc] init];
	self.captureSession.sessionPreset = AVCaptureSessionPresetLow;
	
	AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
	NSError *captureDeviceError = nil;
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&captureDeviceError];
	if ([self.captureSession canAddInput:deviceInput])
		[self.captureSession addInput:deviceInput];
	
	self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
	if ([self.captureSession canAddOutput:self.stillImageOutput])
		[self.captureSession addOutput:self.stillImageOutput];
	
	self.captureOutputView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view insertSubview:self.captureOutputView atIndex:0];
	
	self.capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
	self.capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	self.capturePreviewLayer.frame = self.captureOutputView.layer.bounds;
	[self.captureOutputView.layer addSublayer:self.capturePreviewLayer];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.captureSession startRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.captureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/HUEImageCaptureFramesPerSecond target:self selector:@selector(captureImage) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.captureTimer invalidate];
}

- (void)viewDidLayoutSubviews
{
	CGRect bounds = self.view.bounds;
	
	CGSize debugViewSize = CGSizeMake(floorf(bounds.size.width/2.0), floorf(bounds.size.width/2.0));
	
	self.capturedImageView.frame = CGRectMake(0.0, bounds.size.height - debugViewSize.height, debugViewSize.width, debugViewSize.height);
	self.averageColorView.frame = CGRectMake(CGRectGetMaxX(self.capturedImageView.frame), bounds.size.height - debugViewSize.height, debugViewSize.width, debugViewSize.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
	[[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
}

#pragma mark -

- (void)captureImage
{
	AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in connection.inputPorts)
        {
            if ([port.mediaType isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
		
        if (videoConnection)
			break;
    }
	
	[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
		if (imageDataSampleBuffer && self.canChangeLights)
		{
			NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
			UIImage *image = [[UIImage alloc] initWithData:imageData];
			
			self.capturedImageView.image = image;
			
			[self.averageColorCalculator calculateAverageColorAndBrightnessForImage:image withCompletionBlock:^(UIColor *color, CGFloat brightness) {
				self.averageColorView.backgroundColor = color;
								
				CGPoint XYPoint = CGPointZero;
				[PHUtilities calculateXY:&XYPoint andBrightness:&brightness fromColor:color forModel:nil];
				
				PHLightState *lightState = [[PHLightState alloc] init];
				lightState.x = @(XYPoint.x);
				lightState.y = @(XYPoint.y);
				lightState.brightness = @(abs(brightness));
				
				PHBridgeResourcesCache *bridgeResourceCache = [PHBridgeResourcesReader readBridgeResourcesCache];
				id <PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
				
				for (NSString *key in bridgeResourceCache.lights)
				{
					PHLight *light = [bridgeResourceCache.lights objectForKey:key];
					[bridgeSendAPI updateLightStateForId:light.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
						NSLog(@"Errors: %@", errors);
					}];
				}
			}];
		}
	}];
}

#pragma mark - Heart Beat

- (void)startHeartBeat
{
	PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache && cache.bridgeConfiguration && cache.bridgeConfiguration.ipaddress)
	{
		NSLog(@"Starting heart beat");
		[self.hueSDK enableLocalConnectionUsingInterval:10];
	}
	else
	{
		NSLog(@"No bridge, find one!");
		[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error connecting to bridge, wrong credentials?", nil)];
	}
}

- (void)stopHeartBeat
{
	[self.hueSDK disableLocalConnection];
}

#pragma mark - Notifications

- (void)localConnectionNotification
{
	NSLog(@"Local connection detected");
	self.canChangeLights = YES;
}

- (void)noLocalConnectionNotification
{
	NSLog(@"No local connection");
	self.canChangeLights = NO;
}

- (void)noLocalAuthenticationNotification
{
	NSLog(@"No local authentication");
	
	self.canChangeLights = NO;
	[self.hueSDK disableLocalConnection];
	
	[SVProgressHUD showWithStatus:NSLocalizedString(@"Press the button on the bridge", nil)];
	[self.hueSDK startPushlinkAuthentication];
}

- (void)authenticationSuccessNotification
{
	NSLog(@"Authentication success");
	
	[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Success!", nil)];
	[self startHeartBeat];
	
	self.canChangeLights = YES;
}

@end
