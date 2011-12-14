//
//  ViewController.m
//  iSecureCam
//
//  Created by Jun Xiao on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+OpenCV.h"

#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"


@interface ViewController()
- (void)setupCaptureSession;
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection;
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image;
- (UIImage *)UIImageFromIplImage:(IplImage *)image;
- (void) saveToFile:(UIImage *)image;
- (void) saveViewToFile:(UIView *)someView;
- (void) saveImageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
- (void) delayedCapture;

@property (nonatomic,retain) AVCaptureSession* session;
@property (nonatomic, retain) NSTimer * timer;
@end

@implementation ViewController

@synthesize session;
@synthesize timer;
@synthesize appSettingsViewController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    storage = cvCreateMemStorage(0);
	cvSetErrMode(CV_ErrModeParent);
    
    firstFlag =true;
    captureFlag = false;

    timer = [NSTimer scheduledTimerWithTimeInterval: 30
                                             target: self
                                           selector: @selector(handleTimer:)
                                           userInfo: nil
                                            repeats: YES];
    
    uploadCounter = 0;

    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
   
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            if ([prefSpecification objectForKey:@"DefaultValue"])
                [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
    [defaultsToRegister release];
    
    if (![[NSUserDefaults standardUserDefaults] synchronize])
        NSLog(@"not successful in writing the default prefs");
 }

#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self setupCaptureSession];    
}

- (IBAction)showSettingsPush:(id)sender 
{
    appSettingsViewController = [[[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil] autorelease];
    appSettingsViewController.delegate = self;
    appSettingsViewController.showDoneButton = YES;
    UINavigationController *aNavController = [[[UINavigationController alloc] initWithRootViewController:appSettingsViewController] autorelease];
    [self presentModalViewController:aNavController animated:YES];
}

- (void) handleTimer: (NSTimer *) timer
{

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy HH:mm"];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *dateString = [format stringFromDate:now];
    dateString = [dateString substringWithRange:NSMakeRange(13, 2)];
 
    int h = [dateString intValue];

    if(h>= [[defaults objectForKey:@"startTime_preference"] intValue] && h <= [[defaults objectForKey:@"endTime_preference"] intValue])
    {
        captureFlag = true;
    }
    else
    {
        captureFlag = false;
    }

    [format setDateFormat:@"MMM dd, yyyy"];
    dateString = [format stringFromDate:now];
    [now release];
    [format release];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *flManager = [NSFileManager defaultManager];
    NSArray *ContentOfDirectory=[flManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    
    if([ContentOfDirectory count]==0) return;
        
    NSString *fileName=[ContentOfDirectory objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.fromEmail = [defaults objectForKey:@"emailFrom_preference"];
    NSLog(@"from email %@", testMsg.fromEmail);
    
    testMsg.toEmail = [defaults objectForKey:@"emailTo_preference"];
    testMsg.bccEmail = nil;
    testMsg.relayHost = [defaults objectForKey:@"mailServer_preference"];
    NSLog(@"server address %@", testMsg.relayHost);
   
    testMsg.requiresAuth = YES;
    
    if (testMsg.requiresAuth) {
        testMsg.login = [defaults objectForKey:@"username_preference"];
        testMsg.pass = [defaults objectForKey:@"password_preference"];
    }
    
    testMsg.wantsSecure = [[defaults objectForKey:@"secure_preference"] boolValue]; // smtp.gmail.com doesn't work without TLS!
    testMsg.subject = @"Security camera capture";
    testMsg.delegate = self;
    
    NSString *emailMessage = [NSString stringWithFormat:@"This is a  security camera catpure at %@, %@", dateString, [fileName substringToIndex:8]];

    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                               emailMessage,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    NSData *vcfData = [NSData dataWithContentsOfFile:path];
    NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"image/jpeg;\r\n\tx-unix-mode=0644;\r\n\tname=\"securitycapture.jpg\"",kSKPSMTPPartContentTypeKey,
                             @"attachment;\r\n\tfilename=\"securitycapture.jpg\"",kSKPSMTPPartContentDispositionKey,[vcfData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    testMsg.parts = [NSArray arrayWithObjects:plainPart,vcfPart,nil];
    [testMsg send];
    
    uploadCounter ++;
    [flManager removeItemAtPath: path error:NULL];
} 

- (void)messageSent:(SKPSMTPMessage *)message
{
    [message release];
    NSLog(@"delegate - message sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    NSString *text = [NSString stringWithFormat:@"Error in sending the email (%d): %@", [error code], [error localizedDescription]];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Alert View" message:text delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];    
     NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    cvReleaseImage(&movingAverage);

    cvReleaseMemStorage(&storage);
}




- (void)setupCaptureSession {
        
    NSError *error = nil;
	
    // Create the session
    AVCaptureSession *newSession = [[AVCaptureSession alloc] init];
	
    // Configure the session to produce lower resolution video frames, if your 
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
	newSession.sessionPreset = AVCaptureSessionPreset640x480;
	
    // Find the front camera
    AVCaptureDevice *device = [AVCaptureDevice deviceWithUniqueID:
							   @"com.apple.avfoundation.avcapturedevice.built-in_video:1"];
	
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device 
																		error:&error];
    if (!input) {
        // Handling the error appropriately.
		NSLog(@"could not load input: %@", error);
		return;
    }
    [newSession addInput:input];
	
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    [newSession addOutput:output];
	
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
	
    // Specify the pixel format
    output.videoSettings = 
	[NSDictionary dictionaryWithObject:
	 [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
								forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	output.alwaysDiscardsLateVideoFrames = YES;
	
	
    // If you wish to cap the frame rate to a known value, such as 15 fps, set 
    // minFrameDuration.
 //   output.minFrameDuration = CMTimeMake(1, 15);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [cameraPreview setHidden:true];
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:newSession];
    previewLayer.frame = cameraPreview.bounds; // Assume you want the preview layer to fill the view.
    [cameraPreview.layer addSublayer:previewLayer];

    if(![[defaults objectForKey:@"hide_preference"] boolValue])
    {
        [cameraPreview setHidden:false];
    }
	
    motionStart = false;
	
    // Start the session running to start the flow of data
    [newSession startRunning];
    
    // Assign session to an ivar.
    [self setSession:newSession];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection { 
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    UIImage *uiImage = [self imageFromSampleBuffer:sampleBuffer];
	if (!uiImage) {
		return;
	}
    
    if(!captureFlag)return;
    
    if(motionStart)
    {
//        NSLog(@"motion started:\n");
        float t = 2*((double)cv::getTickCount() - tlog) / cv::getTickFrequency();
        if (t>1)
        {
            tlog = cv::getTickCount();
            [self saveToFile:uiImage];
            motionStart = false;
        } 
    }
    
	IplImage *image = [self CreateIplImageFromUIImage:uiImage];
	
	// Scaling down
	int scale = 2;
	IplImage *smallImage = cvCreateImage(cvSize(image->width/scale, image->height/scale), IPL_DEPTH_8U, 3);
	cvPyrDown(image, smallImage, CV_GAUSSIAN_5x5);
	cvReleaseImage(&image);
	
	// transpose (as video is landscape...)
	IplImage *portraitImage = cvCreateImage(cvSize(smallImage->height, smallImage->width), IPL_DEPTH_8U, 3);
	cvTranspose(smallImage, portraitImage);
	cvReleaseImage(&smallImage);
    CvSize imgSize = cvSize(portraitImage->width, portraitImage->height);
    
    IplImage* greyImage = cvCreateImage( imgSize, IPL_DEPTH_8U, 1);
//    IplImage* colourImage = cvCreateImage( imgSize, IPL_DEPTH_8U, 3);
    IplImage* colourImage;
    IplImage* difference= cvCreateImage( imgSize, IPL_DEPTH_8U, 3);
    IplImage* temp= cvCreateImage( imgSize, IPL_DEPTH_8U, 3);
    IplImage* mTempImage= cvCreateImage( imgSize, IPL_DEPTH_8U, 3);
    
  //  cvConvertScale(portraitImage,colourImage, 1.0, 0.0);
    colourImage = cvCloneImage(portraitImage);

    cvReleaseImage(&portraitImage);

    if (firstFlag)
    {
        difference = cvCloneImage(colourImage);
        movingAverage = cvCreateImage( imgSize, IPL_DEPTH_32F, 3);
        cvConvertScale(colourImage, movingAverage, 1.0, 0.0);
        firstFlag = false;
        fileCounter = 0;
        tlog = (double)cv::getTickCount();
    }
    else
    {
        cvRunningAvg( colourImage, movingAverage, 0.02 ,NULL);
    }
    cvConvertScale(movingAverage,temp, 1.0, 0.0);
    
    cvAbsDiff(colourImage,temp,difference);
    
    cvCvtColor(difference,greyImage,CV_RGB2GRAY);
    
    cvThreshold(greyImage, greyImage, 120, 255, CV_THRESH_BINARY);
    
    cvDilate(greyImage, greyImage, 0, 18);
    cvErode(greyImage, greyImage, 0, 10);
    
    cvClearMemStorage(storage);
    CvSeq* contour = 0;
    cvFindContours( greyImage, storage, &contour, sizeof(CvContour), CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE );
    
    int Disturbances = 0;
     
    for( ; contour != 0; contour = contour->h_next )
    {
        Disturbances++;
    }
    
    if(Disturbances > 0)
    {
 //       NSLog(@"motion detected: %d\n", Disturbances);
//        [self performSelector:@selector(delayedCapture) withObject:nil afterDelay:1];    
        if(!motionStart)
        {
            tlog = (double)cv::getTickCount();
            motionStart = true;
        }    
    }
    
    cvReleaseImage(&temp);
    cvReleaseImage(&difference);
    cvReleaseImage(&greyImage);
    cvReleaseImage(&colourImage);
    cvReleaseImage(&mTempImage);
    
	[pool drain];
}

- (void) delayedCapture
{
    motionStart = true;
    NSLog(@"motion started:\n");
}

- (void) saveToFile:(UIImage *)image{
    if (image != nil)
    {

        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"HH.mm.ss"];
        
        NSDate *now = [[NSDate alloc] init];
        
        NSString *dateString = [format stringFromDate:now];
        
        [now release];
        [format release];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent: 
                          [NSString stringWithFormat: @"%@-%d.jpg", dateString, fileCounter]];
  //      NSData* data = UIImagePNGRepresentation(image);
        NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(image, 0.5f)];//1.0f = 100% quality

        [data writeToFile:path atomically:YES];
        fileCounter ++;
        NSLog(@"save file number: %d", fileCounter);
    }
}

- (void) saveViewToFile:(UIView *)someView{
    UIGraphicsBeginImageContext(someView.bounds.size);
    [someView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self saveToFile:viewImage];
}

// Create a UIImage from sample buffer data
- (void) saveImageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    [self saveToFile:image];
}


// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    if (!colorSpace) {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
	
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer); 
	
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, 
															  NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage = 
	CGImageCreate(width,
				  height,
				  8,
				  32,
				  bytesPerRow,
				  colorSpace,
				  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
				  provider,
				  NULL,
				  true,
				  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
	
    // Create and return an image object representing the specified Quartz image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
	
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	
    return image;
}

// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
- (IplImage *)CreateIplImageFromUIImage:(UIImage *)image {
	// Getting CGImage from UIImage
	CGImageRef imageRef = image.CGImage;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// Creating temporal IplImage for drawing
	IplImage *iplimage = cvCreateImage(
									   cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4
									   );
	// Creating CGContext for temporal IplImage
	CGContextRef contextRef = CGBitmapContextCreate(
													iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
													);
	// Drawing CGImage to CGContext
	CGContextDrawImage(
					   contextRef,
					   CGRectMake(0, 0, image.size.width, image.size.height),
					   imageRef
					   );
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);
	
	// Creating result IplImage
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);
	
	return ret;
}

// NOTE You should convert color mode as RGB before passing to this function
- (UIImage *)UIImageFromIplImage:(IplImage *)image {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// Allocating the buffer for CGImage
	NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
	CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
	// Creating CGImage from chunk of IplImage
	CGImageRef imageRef = CGImageCreate(
										image->width, image->height,
										image->depth, image->depth * image->nChannels, image->widthStep,
										colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
										provider, NULL, false, kCGRenderingIntentDefault
										);
	// Getting UIImage from CGImage
	UIImage *ret = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	return ret;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
