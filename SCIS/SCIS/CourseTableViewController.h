//
//  CourseTableViewController.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/6/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Program.h"
#import "ProgramSvc.h"

/**
 * The table view controller for the Course View Controller in Main.storyboard.
 * The view displays a list of Courses for a specified Program. The view 
 * also displays toolbar buttons allowing the user to share, tweet, or update Facebook,
 * with a message about the selected program and a link to regis.edu.
 */
@interface CourseTableViewController : UITableViewController <ProgramSvcDelegate>

@property (nonatomic, strong) Program *program;

/** methods to support unit testing
 */
- (void) setService:(id <ProgramSvc>) service;
- (BOOL) areCoursesLoaded;

- (IBAction)shareTapped:(id)sender;
- (IBAction)facebookTapped:(id)sender;
- (IBAction)twitterTapped:(id)sender;

@end
