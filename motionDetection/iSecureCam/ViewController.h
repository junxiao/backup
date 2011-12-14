//
//  ViewController.h
//  iSecureCam
//
//  Created by Jun Xiao on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

#include <OpenCV/opencv2/objdetect/objdetect.hpp>

#import <CFNetwork/CFNetwork.h>

#import "SKPSMTPMessage.h"
#import "IASKAppSettingsViewController.h"

@interface ViewController :  UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate,  IASKSettingsDelegate, SKPSMTPMessageDelegate> {

    IASKAppSettingsViewController *appSettingsViewController;
	
    IBOutlet UIView* cameraPreview;
    IBOutlet UIButton* startCameraPreview;
	
	AVCaptureSession* session;
//	CvHaarClassifierCascade* cascade;
    IplImage* movingAverage;
//    IplImage* temp;
	CvMemStorage* storage;
    bool firstFlag;
    bool captureFlag;
    int fileCounter;
    int uploadCounter;
    double tlog;
    NSTimer * timer;
    
    bool motionStart;
    
//    NSString *documentsDirectory;
}
- (IBAction)showSettingsPush:(id)sender;

@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;

@end
