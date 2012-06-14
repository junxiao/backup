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

    int questionNumber;
    int level;
    bool penaltyOn;
    
    int answerNumber;
    
    NSTimeInterval startTime;


}
@property(nonatomic,retain) IBOutlet UILabel *variable1Lbl;
@property(nonatomic,retain) IBOutlet UILabel *variable2Lbl;
@property(nonatomic,retain) IBOutlet UILabel *operatorLbl;


-(IBAction)userDoneEnteringText:(id)sender;
//- (void) setLevel: (int) i;

-(void) resetQuestion;
-(void) endTest;

-(BOOL) checkAnswerOK:(NSString *) answerText;

-(BOOL) isFinal;
-(void) loadSettings;
@end
