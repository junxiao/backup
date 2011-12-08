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

@interface ViewController :  UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
	IBOutlet UIImageView* openCvView;
	IBOutlet UIView* cameraPreview;
	IBOutlet UIView* faceRectsView;
	IBOutlet UIView* legoControlView;
	
	AVCaptureSession* session;
	CvHaarClassifierCascade* cascade;
	CvMemStorage* storage;
}
@end
