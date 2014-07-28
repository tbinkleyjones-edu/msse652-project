//
//  CourseTableViewController.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/6/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"

/**
 The table view controller for the Course View Controller in Main.storyboard
 */
@interface CourseTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) Program *program;

@end
