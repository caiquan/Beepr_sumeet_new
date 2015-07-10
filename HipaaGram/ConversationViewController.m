/*
 * Copyright (C) 2014 Catalyze, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import "ConversationViewController.h"
#import "Message.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "MessageTableViewCell.h"

@interface ConversationViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tblMessages;
@property (strong, nonatomic) NSMutableArray *messages;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UITextField *txtMessage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTableConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topTableConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation ConversationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.navigationController.navigationBar.isTranslucent) {
        _topTableConstraint.constant = 64.0;
        _bottomTableConstraint.constant = -64.0;
    }
    
    _btnSend.layer.cornerRadius = 5;
    _btnSend.enabled = NO;
    
    self.title = _username;
    
    _messages = [NSMutableArray array];
    
    [_txtMessage addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [_tblMessages addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)]];
    _tblMessages.estimatedRowHeight = 97;
    _tblMessages.rowHeight = UITableViewAutomaticDimension;
    [_tblMessages registerNib:[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil] forCellReuseIdentifier:@"MessageCellIdentifier"];
    _tblMessages.transform = CGAffineTransformMakeRotation(-M_PI);
    
    [self queryMessages];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self scrollToBottomAnimated:NO];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setHandler:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [((AppDelegate *)[UIApplication sharedApplication].delegate) setHandler:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboard {
    [_txtMessage resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _bottomConstraint.constant = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height + 8;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _bottomConstraint.constant = 8;
}

- (IBAction)sendMessage:(id)sender {
    if ([_txtMessage.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        return;
    }
    [_txtMessage resignFirstResponder];
    Message *msg = [[Message alloc] initWithClassName:@"messages"];
    [[msg content] setValue:_txtMessage.text forKey:@"msgContent"];
    [[msg content] setValue:_username forKey:@"toPhone"];
    [[msg content] setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername] forKey:@"fromPhone"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd-yyyy HH:mm:ss.SSSSSS"];
    
    [[msg content] setValue:[format stringFromDate:[NSDate date]] forKey:@"timestamp"];
    [[msg content] setValue:_txtMessage.text forKey:@"msgContent"];
    [[msg content] setValue:[NSNumber numberWithBool:NO] forKey:@"isPhi"];
    [[msg content] setValue:@"" forKey:@"fileId"];
    [[msg content] setValue:_conversationsId forKey:@"conversationsId"];
    [msg createInBackgroundWithSuccess:^(id result) {
        // do nothing
    } failure:^(NSDictionary *result, int status, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not send the message: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
    
    [_messages addObject:msg];
    _txtMessage.text = @"";
    _btnSend.enabled = NO;
    [_tblMessages reloadData];
    [self scrollToBottomAnimated:YES];
    
    [msg createInBackgroundForUserWithUsersId:_userId success:^(id result) {
        NSLog(@"successfully saved msg");
        [self sendNotification];
    } failure:^(NSDictionary *result, int status, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not send the message: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    _btnSend.enabled = _txtMessage.text.length > 0;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if (_messages.count > 0) {
        [_tblMessages scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)queryMessages {
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:@"messages"];
    query.queryField = @"conversationsId";
    query.queryValue = _conversationsId;
    query.pageNumber = 1;
    query.pageSize = 100;
    [query retrieveInBackgroundWithSuccess:^(NSArray *result) {
        [_messages removeAllObjects];
        for (CatalyzeEntry *entry in result) {
            // can't query by conversationsId and parentId, so we have to filter once we get the results back
            if ([[entry parentId] isEqualToString:[[CatalyzeUser currentUser] usersId]]) {
                [_messages addObject:[[Message alloc] initWithClassName:@"messages" dictionary:[entry content]]];
            }
        }
        [_messages sortUsingComparator:^NSComparisonResult(Message *msg1, Message *msg2) {
            return [[[msg1 content] valueForKey:@"timestamp"] compare:[[msg2 content] valueForKey:@"timestamp"]];
        }];
        [_tblMessages reloadData];
        //[self scrollToBottomAnimated:YES];
    } failure:^(NSDictionary *result, int status, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not fetch previous messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

- (void)sendNotification {
    AFHTTPRequestOperationManager *client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://go.urbanairship.com"]];
    client.requestSerializer = [AFJSONRequestSerializer serializer];
    [client.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    client.responseSerializer = [AFHTTPResponseSerializer serializer];
    [client.operationQueue setMaxConcurrentOperationCount:1];
    
    NSDictionary *ua = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AirshipConfig" ofType:@"plist"]];
    [client.requestSerializer setAuthorizationHeaderFieldWithUsername:[ua valueForKey:@"developmentAppKey"] password:[ua valueForKey:@"developmentMasterSecret"]];
    
    NSMutableDictionary *notification = [NSMutableDictionary dictionary];
    [notification setValue:@"all" forKey:@"device_types"];
    [notification setValue:@{@"alert":[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]} forKey:@"notification"];
    [notification setValue:@[_username] forKey:@"aliases"];
    
    [client POST:@"/api/push/" parameters:notification success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"successfully sent push notification");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", error);
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not notify the recipient, they must refresh manually" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

#pragma mark - PushNotificationHandler

- (void)handleNotification:(NSString *)fromNumber {
    NSLog(@"I got a msg, querying for it...");
    [self queryMessages];
}

#pragma mark - UITableViewDataSource
#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCellIdentifier"];
    Message *message = [_messages objectAtIndex:indexPath.row];
    BOOL sender = [[[message content] valueForKey:@"fromPhone"] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername]];
    [cell initializeWithMessage:message sender:sender];
    cell.contentView.transform = CGAffineTransformMakeRotation(M_PI);
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _messages.count;
}

@end
