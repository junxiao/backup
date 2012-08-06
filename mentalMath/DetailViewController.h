//
//  DetailViewController.h
//  mentalMath
//
//  Created by Jun Xiao on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController
{
    NSMutableArray *mistakes;

}
- (id)initWithStyle:(UITableViewStyle)style andData:(NSString *) misktakesData;


@end
