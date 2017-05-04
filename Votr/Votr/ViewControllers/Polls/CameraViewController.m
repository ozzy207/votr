//
//  CameraViewController.m
//  Votr
//
//  Created by Edward Kim on 1/15/17.
//  Copyright © 2017 DEDStop LLC. All rights reserved.
//

#import "CameraViewController.h"
#import "BRProgressCircleView.h"

@interface CameraViewController ()
@property (strong, nonatomic) IBOutlet BRProgressCircleView *progressCircleView;
@property (strong, nonatomic) IBOutlet UIButton *cameraToggle;
@property (strong, nonatomic) UIButton *flashButton;
@property (strong, nonatomic) UILabel *errorLabel;
@end

@implementation CameraViewController


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		
	}
	return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self stop];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self authorizeMediaType:AVMediaTypeVideo authorized:^(BOOL authorized) {
		if (authorized) {
			[self authorizeMediaType:AVMediaTypeAudio authorized:^(BOOL authorized) {
				if (!authorized) {
					[self showEnableDeviceAlert];
				}
			}];
		}else{
			[self showEnableDeviceAlert];
			
		}
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	// start the camera
	[self start];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.view bringSubviewToFront:self.progressCircleView];
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	__weak typeof(self) weakSelf = self;
	[self setOnDeviceChange:^(LLSimpleCamera *camera, AVCaptureDevice * device) {
		
		NSLog(@"Device changed.");
		if (![camera isRunning]) {
			[weakSelf start];
		}
		// device changed, check if flash is available
		if([camera isFlashAvailable]) {
			weakSelf.flashButton.hidden = NO;
			
			if(camera.flash == LLCameraFlashOff) {
				weakSelf.flashButton.selected = NO;
			}
			else {
				weakSelf.flashButton.selected = YES;
			}
		}
		else {
			weakSelf.flashButton.hidden = YES;
		}
	}];
	
	[self setOnError:^(LLSimpleCamera *camera, NSError *error) {
		NSLog(@"Camera error: %@", error);
		
		if([error.domain isEqualToString:LLSimpleCameraErrorDomain]) {
			if(error.code == LLSimpleCameraErrorCodeCameraPermission ||
			   error.code == LLSimpleCameraErrorCodeMicrophonePermission) {
				
				if(weakSelf.errorLabel) {
					[weakSelf.errorLabel removeFromSuperview];
				}
				
				UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
				label.text = @"We need permission for the camera.\nPlease go to your settings.";
				label.numberOfLines = 2;
				label.lineBreakMode = NSLineBreakByWordWrapping;
				label.backgroundColor = [UIColor clearColor];
				label.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.0f];
				label.textColor = [UIColor whiteColor];
				label.textAlignment = NSTextAlignmentCenter;
				[label sizeToFit];
				label.center = CGPointMake(screenRect.size.width / 2.0f, screenRect.size.height / 2.0f);
				weakSelf.errorLabel = label;
				[weakSelf.view addSubview:weakSelf.errorLabel];
			}
		}
	}];
	
	if([LLSimpleCamera isFrontCameraAvailable] && [LLSimpleCamera isRearCameraAvailable]) {
		// button to toggle camera positions
		[self.cameraToggle setAlpha:1];
	}else{
		[self.cameraToggle setAlpha:0];
	}
	
	self.progressCircleView.progress = ^(double progress){
		NSLog(@"%f",progress);
	};
	
	self.progressCircleView.completion = ^(){
		NSLog(@"DONE");
		[weakSelf.progressCircleView resetAnimation];
		if ([weakSelf isRecording]) {
			
			[weakSelf stopRecording:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
				weakSelf.contentCaptured(outputFileUrl,nil);
				[weakSelf dismissViewControllerAnimated:YES completion:nil];
				//[weakSelf.imageVideoController setVideoURL:outputFileUrl];
			}];
		}
	};

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)takePicture:(id)sender
{
	NSLog(@"Take Picture");
	if (![self hasVideoSession]) {
		return;
	}
	
	[self capture:^(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error) {
		if(!error) {
			self.contentCaptured(nil,image);
			[self dismissViewControllerAnimated:YES completion:nil];
			//[self.imageVideoController setImage:image];
			//[self showUIComponents:NO];
		}
		else {
			NSLog(@"An error has occured: %@", error);
		}
	} exactSeenImage:YES];
}

- (IBAction)takeVideo:(UILongPressGestureRecognizer*)sender
{
	if (self.disableVideo) {
		return;
	}
	if (sender.state == UIGestureRecognizerStateEnded) {
		NSLog(@"UIGestureRecognizerStateEnded");
		[self.progressCircleView resetAnimation];
		
		if ([self isRecording]) {
			
			[self stopRecording:^(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error) {
				self.contentCaptured(outputFileUrl,nil);
				[self dismissViewControllerAnimated:YES completion:nil];
//				[self.imageVideoController setVideoURL:outputFileUrl];
//				[self showUIComponents:NO];
			}];
		}
		
		//[self.camera stopRecording];
		//Do Whatever You want on End of Gesture
	}
	else if (sender.state == UIGestureRecognizerStateBegan){
		NSLog(@"UIGestureRecognizerStateBegan.");
		NSLog(@"Take Video");
		if (![self isRecording]) {
			// start recording
			
			NSURL *outputURL = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@(self.index).stringValue] URLByAppendingPathExtension:@"mov"];
			[self startRecordingWithOutputUrl:outputURL];
			[self.progressCircleView setPercentage:100];
		}
		
		//Do Whatever You want on Began of Gesture
	}
}




- (void)authorizeMediaType:(NSString*)mediaType authorized:(void(^)(BOOL authorized))_authorized
{
	
	BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
	if (!hasCamera) {
		_authorized(NO);
		return;
	}
	
	AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
	if(authStatus == AVAuthorizationStatusAuthorized) {
		// do your logic
		_authorized(YES);
	}else if(authStatus == AVAuthorizationStatusDenied){
		// denied
		_authorized(NO);
	}else if(authStatus == AVAuthorizationStatusRestricted){
		// restricted, normally won't happen
		_authorized(YES);
	}else if(authStatus == AVAuthorizationStatusNotDetermined){
		// not determined?!
		[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
			_authorized(granted);
		}];
	}else {
		// impossible, unknown authorization status
		_authorized(NO);
	}
}



- (void)showEnableDeviceAlert
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This app does no have access to your camera or microphone" message:@"You can enable access in Privacy Settings." preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	
	UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary new] completionHandler:^(BOOL success) {
			[self dismissViewControllerAnimated:NO completion:nil];
			
		}];
	}];
	
	[alert addAction:ok];
	[alert addAction:settings];
	
	[self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Directory
- (NSURL *)applicationDocumentsDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
