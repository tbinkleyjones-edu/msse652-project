//
//  ProgramsViewControllerTableViewController.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/5/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "ProgramTableViewController.h"
#import "ProgramSvc.h"
#import "ProgramSvcJson.h"
#import "CourseTableViewController.h"

@interface ProgramTableViewController ()

@end

@implementation ProgramTableViewController {
    id <ProgramSvc> _service;
    NSArray *_programs;
}

- (void) setService:(id <ProgramSvc>) service {
    _service = service;
    [_service setDelegate:self];
    [_service retrieveProgramsAsync];
}
- (BOOL) areProgramsLoaded {
    return _programs != nil;
}


#pragma mark - UIViewController


//- (void)awakeFromNib
//{
//    [super awakeFromNib];
//    NSLog(@"awakeFromNib");
//}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    NSLog(@"initWithStyle");
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");

    if (_service == nil) {
        [self setService:[[ProgramSvcJson alloc] init]];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    NSLog(@"viewWillAppear");
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    NSLog(@"viewDidAppear");
//}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Only one section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of programs.
    return _programs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProgramCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Program *program = [[_service retrievePrograms] objectAtIndex:indexPath.row];
    cell.textLabel.text = program.name;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.

    if ([[segue identifier] isEqualToString:@"FromProgramToCourse"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Program *program = [_programs objectAtIndex:indexPath.row];
        [[segue destinationViewController] setProgram:program];
    }
}

#pragma mark - ProgramSvcDelegate

- (void)didFinishRetrievingPrograms:(NSArray *)programs {
    _programs = programs;
    [self.tableView reloadData];
    NSLog(@"programs loaded");
}

- (void)didFinishRetrievingCourses:(NSArray *)courses {

}

@end
