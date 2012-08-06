//
//  LogViewController.h
//  mentalMath
//
//  Created by Jun Xiao on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Dfetch.h"
#import "/usr/include/sqlite3.h"
#import "DetailViewController.h"

@interface LogViewController : UITableViewController
{
    Dfetch *dao;
}
-(IBAction)clearButtonClick:(id)sender;

@end
