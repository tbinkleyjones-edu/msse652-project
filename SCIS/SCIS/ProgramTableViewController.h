//
//  ProgramsViewControllerTableViewController.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/5/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgramSvc.h"

@interface ProgramTableViewController : UITableViewController <ProgramSvcDelegate>

/** methods to support unit testing
 */
- (void) setService:(id <ProgramSvc>) service;
- (BOOL) areProgramsLoaded;

@end
