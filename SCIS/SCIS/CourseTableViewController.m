//
//  CourseTableViewController.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 7/6/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "CourseTableViewController.h"
#import "Course.h"
#import "RestKit.h"

@interface CourseTableViewController ()

@end

@implementation CourseTableViewController {
    NSArray *_courses;
    NSFetchedResultsController *_fetchedResultsController;
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Course class])];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];

        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];

        _fetchedResultsController.delegate = self;

        NSError *error;
        BOOL fetchSuccessful = [_fetchedResultsController performFetch:&error];
        NSLog(@"%@", [_fetchedResultsController fetchedObjects]);
        NSAssert(!error, @"Error performing fetch request: %@", error);

        //NSAssert([[self.fetchedResultsController fetchedObjects] count], @"Seeding didn't work...");
        if (! fetchSuccessful) {
            NSLog(@"fetch didn't work");
        }
    }
    return _fetchedResultsController;
}


#pragma mark - UIViewController

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
    NSLog(@"viewDidLoad");
    [super viewDidLoad];

    _fetchedResultsController = [self fetchedResultsController];
    [self loadData];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) loadData {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/Regis2/webresources/regis2.course" parameters:nil
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

                                                  NSArray *fetchedObjects = [_fetchedResultsController fetchedObjects];
                                                  NSMutableArray *results = [[NSMutableArray alloc] init];
                                                  for (int i=0; i<fetchedObjects.count; i++) {
                                                      Course *course = [fetchedObjects objectAtIndex:i];
                                                      if (course.pid.id == self.program.id) {
                                                          [results addObject:course];
                                                      }
                                                  }
                                                  _courses = results;
                                                  RKLogInfo(@"Load complete: Table should refresh...");
                                                  NSLog(@"%@", _courses);
                                                  [self.tableView reloadData];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  RKLogInfo(@"Load failure...");
                                              }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Only one section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _courses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourseCell" forIndexPath:indexPath];
    
    // The cell is configured in Main.storyboard with the Subtitle style, so
    // both the primary text and detail text labels are used.
    Course *course = [_courses objectAtIndex:indexPath.row];

    // TODO: split the course name into "course number" and "course name"
    cell.textLabel.text = course.name; // i.e. "CIS 206"
    cell.detailTextLabel.text = @"couse name"; // i.e. "Business Software Applications"

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSLog(@"content changed");
    [self.tableView reloadData];
}

@end
