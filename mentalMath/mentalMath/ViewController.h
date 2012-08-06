//
//  ViewController.h
//  mentalMath
//
//  Created by Jun Xiao on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{

    IBOutlet UILabel *variable1Lbl;
    IBOutlet UILabel *variable2Lbl;
    IBOutlet UILabel *operatorLbl;
    IBOutlet UITextField *textField;

    int questionNumber;
    int questionNumberTotal;
    int mistakeNumber;
    int level;
    bool penaltyOn;
    
    int answerNumber;
    
    NSTimeInterval startTime;
    NSMutableArray *logArray; 
    NSMutableString *mistakeString;

}
@property(nonatomic,retain) IBOutlet UILabel *variable1Lbl;
@property(nonatomic,retain) IBOutlet UILabel *variable2Lbl;
@property(nonatomic,retain) IBOutlet UILabel *operatorLbl;
@property(nonatomic,retain) IBOutlet UITextField *textField;




-(void) resetQuestion;
-(void) endTest;

-(BOOL) checkAnswerOK:(NSString *) answerText;

-(void) loadSettings;
@end
