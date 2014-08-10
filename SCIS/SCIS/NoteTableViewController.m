//
//  NoteTableViewController.m
//  SCIS
//
//  Created by Tim Binkley-Jones on 8/9/14.
//  Copyright (c) 2014 msse652. All rights reserved.
//

#import "NoteTableViewController.h"
#import "NoteViewController.h"
#import "NoteSvcCloud.h"

@interface NoteTableViewController ()

@end

@implementation NoteTableViewController {
    id <NoteSvc> _service;
    NSArray *_notes;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // add the plus button
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;

    // create the NoteSvc and reload data whenever the service updates the collection of notes
    _service = [[NoteSvcCloud alloc] initWithHandler:^{
        NSLog(@"reloading data");
        _notes = [_service retrieveAllNotes];
        [self.tableView reloadData];
    }];
    _notes = [NSMutableArray arrayWithArray:[_service retrieveAllNotes]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    Note *note = [[Note alloc] init];
    note.notes = @"new note";
    note.date = [NSDate date];

    [_service addNote:note];
    // there is no need to update the table view since the service will callback
    // to the handler which in turn calls reloadData.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // All notes are shown in a single section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _notes.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // In the storyboard, the cell is declared with identifier "NoteCell", and is configured
    // with the Subtitle style.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell" forIndexPath:indexPath];

    // construct a date formatter to nicely format the date that is displayed in the subtitle line
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];

    Note *note = _notes[indexPath.row];
    cell.textLabel.text = note.notes;
    cell.detailTextLabel.text = [dateFormatter stringFromDate:note.date];
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source. There is no need to update
        // the table view, as the service callback will call reloadData.
        [_service deleteNote:[_notes objectAtIndex:indexPath.row]];
    }
//    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}


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
    NSLog(@"prepareForSeque %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"FromNotesToNote"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Note *note = _notes[indexPath.row];
        // the detail view needs both the note, and the service (in order to call updateNote)
        [[segue destinationViewController] setService:_service];
        [[segue destinationViewController] setDetailItem:note];
    }
}


@end
