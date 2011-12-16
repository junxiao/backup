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
#import "iAd/ADBannerView.h"

@interface ViewController :  UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate,  IASKSettingsDelegate, ADBannerViewDelegate, SKPSMTPMessageDelegate> {

    IASKAppSettingsViewController *appSettingsViewController;
	
    IBOutlet UIView* cameraPreview;
    IBOutlet UIButton* startCameraPreview;
    IBOutlet UILabel* motionLabel;
	
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
    int sensibilityValue;
    bool showAds;
    bool hideCameraView;
    
    ADBannerView *adView;
    BOOL bannerIsVisible;
    
//    NSString *documentsDirectory;
}
- (IBAction)showSettingsPush:(id)sender;

@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic,assign) BOOL bannerIsVisible;
@end
