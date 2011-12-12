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

@interface ViewController :  UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate,  SKPSMTPMessageDelegate> {
	IBOutlet UIImageView* openCvView;
	IBOutlet UIView* cameraPreview;
	IBOutlet UIView* diffView;
	IBOutlet UIView* colorView;
	
	AVCaptureSession* session;
//	CvHaarClassifierCascade* cascade;
    IplImage* movingAverage;
//    IplImage* temp;
	CvMemStorage* storage;
    bool firstFlag;
    int fileCounter;
    int uploadCounter;
    double tlog;
    NSTimer * timer;
    
//    NSString *documentsDirectory;
}
@end
