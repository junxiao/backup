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

@property (nonatomic,retain) AVCaptureSession* session;
@property (nonatomic, retain) NSTimer * timer;
@end

@implementation ViewController

@synthesize session;
@synthesize timer;

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
    
//	NSString *path = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
//	NSLog(@"loading cascade from %@", path);
    
 //   IplImage* hack = cvCreateImage(cvSize(320,240),IPL_DEPTH_8U,1);  
//	cascade = (CvHaarClassifierCascade*)cvLoad([path cStringUsingEncoding:NSASCIIStringEncoding], NULL, NULL, NULL);
    
    firstFlag =true;

    timer = [NSTimer scheduledTimerWithTimeInterval: 60
                                             target: self
                                           selector: @selector(handleTimer:)
                                           userInfo: nil
                                            repeats: YES];
    
/*     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
   NSMutableDictionary *defaultsDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"julianxiao@gmail.com", @"fromEmail",
                                               @"julianxiao@gmail.com", @"toEmail",
                                               @"smtp.gmail.com", @"relayHost",
                                               @"julianxiao@gmail.com", @"login",
                                               @"njiang75", @"pass",
                                               [NSNumber numberWithBool:YES], @"requiredAuth",
                                               [NSNumber numberWithBool:YES], @"wantsSecure", nil];
    
    [userDefaults registerDefaults:defaultsDictionary]; */
    
    uploadCounter = 0;

	[self setupCaptureSession];

}
- (void) handleTimer: (NSTimer *) timer
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *flManager = [NSFileManager defaultManager];
    NSArray *ContentOfDirectory=[flManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    
    if([ContentOfDirectory count]==0) return;
    
    NSString *fileName=[ContentOfDirectory objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    

//    NSString* path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"test%d.jpg", uploadCounter]];
    
  
/*    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.fromEmail = [defaults objectForKey:@"fromEmail"];
    
    testMsg.toEmail = [defaults objectForKey:@"toEmail"];
    testMsg.bccEmail = [defaults objectForKey:@"bccEmal"];
    testMsg.relayHost = [defaults objectForKey:@"relayHost"];
    
    testMsg.requiresAuth = [[defaults objectForKey:@"requiresAuth"] boolValue];
    
    if (testMsg.requiresAuth) {
        testMsg.login = [defaults objectForKey:@"login"];
        
        testMsg.pass = [defaults objectForKey:@"pass"];
        
    }
    
    testMsg.wantsSecure = [[defaults objectForKey:@"wantsSecure"] boolValue]; // smtp.gmail.com doesn't work without TLS!
  */  
    
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.fromEmail = @"julianxiao@gmail.com";
    
    testMsg.toEmail = @"how28donut@photos.flickr.com";
    testMsg.bccEmail = nil;
    testMsg.relayHost =  @"smtp.gmail.com";
    
    testMsg.requiresAuth = YES;
    
    if (testMsg.requiresAuth) {
        testMsg.login = @"julianxiao@gmail.com";
        
        testMsg.pass = @"njiang75";
        
    }
    
    testMsg.wantsSecure = YES; // smtp.gmail.com doesn't work without TLS
    testMsg.subject = @"Security camera capture";

    // testMsg.validateSSLChain = NO;
    testMsg.delegate = self;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, yyyy "];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *dateString = [format stringFromDate:now];
     
    [now release];
    [format release];
    
    NSString *emailMessage = [NSString stringWithFormat:@"This is a  security camera catpure at %@%@", dateString, [fileName substringToIndex:8]];

    
    NSDictionary *plainPart = [NSDictionary dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
                               emailMessage,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    NSData *vcfData = [NSData dataWithContentsOfFile:path];
    NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:@"image/jpeg;\r\n\tx-unix-mode=0644;\r\n\tname=\"securitycapture.jpg\"",kSKPSMTPPartContentTypeKey,
                             @"attachment;\r\n\tfilename=\"securitycapture.jpg\"",kSKPSMTPPartContentDispositionKey,[vcfData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
    
    testMsg.parts = [NSArray arrayWithObjects:plainPart,vcfPart,nil];
    [testMsg send];
    
    uploadCounter ++;
    [flManager removeItemAtPath: path error:NULL];
} // handleTimer

- (void)messageSent:(SKPSMTPMessage *)message
{
    [message release];
    NSLog(@"delegate - message sent");
}

- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error
{
    
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
	
	AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:newSession];
	previewLayer.frame = cameraPreview.bounds; // Assume you want the preview layer to fill the view.
	[cameraPreview.layer addSublayer:previewLayer];
	
    // Start the session running to start the flow of data
    [newSession startRunning];

//    [previewLayer release];
    
    // Assign session to an ivar.
    [self setSession:newSession];
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection { 
	//return;
    // Create a UIImage from the sample buffer data
    UIImage *uiImage = [self imageFromSampleBuffer:sampleBuffer];
	if (!uiImage) {
		return;
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
    
    cvThreshold(greyImage, greyImage, 150, 255, CV_THRESH_BINARY);
    
    cvDilate(greyImage, greyImage, 0, 18);
    cvErode(greyImage, greyImage, 0, 10);
    
    cvClearMemStorage(storage);
    CvSeq* contour = 0;
    cvFindContours( greyImage, storage, &contour, sizeof(CvContour), CV_RETR_CCOMP, CV_CHAIN_APPROX_SIMPLE );
    
/*    CvRect bndRect = cvRect(0,0,0,0);
    CvPoint pt1, pt2;
    int avgX = 0; */
    int Disturbances = 0;
    bool enter =0;

    
    for( ; contour != 0; contour = contour->h_next )
    {
        enter=1;
 /*       bndRect = cvBoundingRect(contour, 0);
        pt1.x = bndRect.x;
        pt1.y = bndRect.y;
        pt2.x = bndRect.x + bndRect.width;
        pt2.y = bndRect.y + bndRect.height;
        avgX = (pt1.x + pt2.x) / 2;
        
        CvPoint avg;
        avg.x = (pt1.x+pt2.x)/2;
        avg.y = (pt1.y+pt2.y)/2;
  //      cvRectangle(colourImage, pt1, pt2, CV_RGB(255,0,0), 0.5);
        //mTempImage =  cvCloneImage(colourImage);
  //      cvCvtColor(colourImage,mTempImage,CV_RGB2GRAY);
        
        //      colourImage = mTempImage;
        //      cvCircle(colourImage, avg, 5, CV_RGB(255,0,205), 2, 1, 1); */
        Disturbances++;
        
    }
    if(Disturbances > 0)
    {
        NSLog(@"motion detected: %d\n", Disturbances);
        float t = 2*((double)cv::getTickCount() - tlog) / cv::getTickFrequency();
        if (t>1)
        {
        
            tlog = cv::getTickCount();
 //           UIImage* colorRectView = [self UIImageFromIplImage:colourImage];

            [self saveToFile:uiImage];
        }
    }
    
/*	NSArray* subviews = [diffView subviews];
	for (UIView* subview in subviews) {
		[subview performSelectorOnMainThread:@selector(removeFromSuperview)
								  withObject:nil waitUntilDone:YES];
	}

    cvCvtColor( greyImage, mTempImage, CV_GRAY2BGR );

    UIImage* faceRectView = [self UIImageFromIplImage:mTempImage];
    UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:faceRectView];

    [overlayImageView setFrame:CGRectMake(0, 0, 150, 150)];
    [diffView performSelectorOnMainThread:@selector(addSubview:) withObject:overlayImageView waitUntilDone:YES];
    [overlayImageView release];
    [faceRectView release]; 
		
	subviews = [colorView subviews];
	for (UIView* subview in subviews) {
		[subview performSelectorOnMainThread:@selector(removeFromSuperview)
								  withObject:nil waitUntilDone:YES];
	}
    
    
    UIImage* colorRectView = [self UIImageFromIplImage:colourImage];
    UIImageView *overlaycolorImageView = [[UIImageView alloc] initWithImage:colorRectView];
    
    [overlaycolorImageView setFrame:CGRectMake(0, 0, 150, 150)];
    [colorView performSelectorOnMainThread:@selector(addSubview:) withObject:overlaycolorImageView waitUntilDone:YES];
    [overlaycolorImageView release];
    [colorRectView release]; 
*/
    
    cvReleaseImage(&temp);
    cvReleaseImage(&difference);
    cvReleaseImage(&greyImage);
    cvReleaseImage(&colourImage);
    cvReleaseImage(&mTempImage);
 //   [uiImage release];         

	// Detect faces
/*    cvClearMemStorage(storage);
	CvSeq* faces = cvHaarDetectObjects(portraitImage, cascade, storage, 1.2f, 2,
									   CV_HAAR_FIND_BIGGEST_OBJECT | CV_HAAR_DO_ROUGH_SEARCH,
									   cvSize(30, 30));
	cvReleaseImage(&portraitImage);
	NSLog(@"found %d faces in image", faces->total);
	
	UIColor* legoControlColor = [UIColor grayColor];
	
	NSArray* subviews = [faceRectsView subviews];
	for (UIView* subview in subviews) {
		[subview performSelectorOnMainThread:@selector(removeFromSuperview)
								  withObject:nil waitUntilDone:YES];
	}
	CGRect containerFrame = cameraPreview.frame;
	float containerScale = 320.0 / containerFrame.size.width;
	NSLog(@"container: %@, scale: %.2f", NSStringFromCGRect(containerFrame), containerScale);
	for (int i = 0; i < faces->total; i++) {
		CvRect cvrect = *(CvRect*)cvGetSeqElem(faces, i);
		NSLog(@"cvrect: {{%d,%d},{%d,%d}}", cvrect.x, cvrect.y, cvrect.width, cvrect.height);
		CGRect faceRect = CGRectMake(cvrect.x * containerScale, cvrect.y * containerScale,
									 cvrect.width * containerScale, cvrect.height * containerScale);
		NSLog(@"faceRect: %@", NSStringFromCGRect(faceRect));
		UIView* faceRectView = [[UIView alloc] initWithFrame:faceRect];
		[faceRectView setOpaque:NO];
		[faceRectView setAlpha:0.4];
		[faceRectView setBackgroundColor:[UIColor whiteColor]];
		[[faceRectView layer] setBorderColor:[[UIColor redColor] CGColor]];
		[[faceRectView layer] setBorderWidth:1.0f];
		[faceRectsView performSelectorOnMainThread:@selector(addSubview:) withObject:faceRectView waitUntilDone:YES];
		[faceRectView release]; 
		
		if (i == 0) {
			CGFloat faceXPos = faceRect.origin.x + faceRect.size.width / 2;
			CGFloat whiteValue = faceXPos / containerFrame.size.width;
			legoControlColor = [UIColor colorWithWhite:whiteValue alpha:1.0];
		}
	}
	[legoControlView performSelectorOnMainThread:@selector(setBackgroundColor:)
									  withObject:legoControlColor waitUntilDone:YES]; */
	
    //	[openCvView performSelectorOnMainThread:@selector(setImage:) withObject:uiImage waitUntilDone:YES];
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
    }
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
