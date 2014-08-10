//
//  NoteViewController.h
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/9/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteSvc.h"

/**
 * The table view controller for the Note View Controller in Main.storyboard.
 * The views displays a text field allow the user to edit a Note
 */
@interface NoteViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) id <NoteSvc> service;

@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@end
