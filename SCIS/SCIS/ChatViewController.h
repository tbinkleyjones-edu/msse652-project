//
//  ChatViewController.h
//  
//
//  Created by Tim Binkley-Jones on 8/16/14.
//
//

#import <UIKit/UIKit.h>

/**
 * The ui view controller for the Chat View Controller in Main.storyboard.
 * The view displays a text input field and send button, and also a table view.
 * The table displays a list of recent chats sent to or received from the Regis chat server.
 */
@interface ChatViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

- (IBAction)sendMessage:(id)sender;

@end
