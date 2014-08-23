//
//  ChatViewController.m
//  
//
//  Created by Tim Binkley-Jones on 8/16/14.
//
//

#import "ChatViewController.h"
//#import "ChatSvcCF.h"
#import "ChatSvcSR.h"

/** 
 * A private class used to pair message text with the text from a sender.
 */
@interface Message : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *sender;

@end

@implementation Message

@end


@interface ChatViewController ()

@end

@implementation ChatViewController {
    NSMutableArray *_messages;
    id <ChatSvc> _service;
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Hook up this controller with the table view.
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;

    _messages = [[NSMutableArray alloc] init];

    // initialize and connect the chat service
    _service = [[ChatSvcSR alloc] initWithHandler:^(NSString *messageText) {
        // the handler creates a Message object, adds it to the colletion, and tells the table view to reload.
        Message *message = [[Message alloc] init];
        message.text = messageText;
        message.sender = @"Regis";
        
        [_messages addObject:message];
        [self.chatTableView reloadData];
    }];
    [_service connect];
}

- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    // disconnect the service before we leave.
    [_service disconnect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate



#pragma mark - table vie data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // only 1 section of messages.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // number of message is what is in the array
    return _messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s", __PRETTY_FUNCTION__);

    // In the storyboard, the cell is declared with identifier "ChatCell", and is configured
    // with the Subtitle style. The primary label shows the message, the detail label shows the sender.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatCell" forIndexPath:indexPath];

    Message *message = _messages[indexPath.row];
    cell.textLabel.text = message.text;
    cell.detailTextLabel.text = message.sender;
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma chat view controller
/**
 * An aciton called when the send button is clicked
 */
- (IBAction)sendMessage:(id)sender {

    NSString *messageText = [NSString stringWithFormat:@"%@\n", self.messageTextField.text];
    if (messageText.length > 0) {
        // construct a new message object and add it to the array.
        Message *message = [[Message alloc]init];
        message.text = messageText;
        message.sender  = @"You";

        [_messages addObject:message];
        [self.chatTableView reloadData];

        // send the message via the chat service
        [_service send:messageText];
    }

    // clear the message text and dismiss the keyboard
    self.messageTextField.text = nil;
    [self.messageTextField resignFirstResponder];
}
@end
