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

#import "ConversationListViewController.h"
#import "ConversationListTableViewCell.h"
#import "ConversationViewController.h"
#import "ContactsViewController.h"
#import "Catalyze.h"

@interface ConversationListViewController ()

@property (strong, nonatomic) NSMutableArray *conversations;

@end

@implementation ConversationListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Conversations";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addConversation)];
    
    _conversations = [NSMutableArray array];
    
    [_tblConversationList registerNib:[UINib nibWithNibName:@"ConversationListTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ConversationListCellIdentifier"];
    [_tblConversationList reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchConversationList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchConversationList {
    _conversations = [NSMutableArray array];
    CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:@"conversations"];
    [query setPageNumber:1];
    [query setPageSize:20];
    [query retrieveInBackgroundWithSuccess:^(NSArray *result) {
        [_conversations addObjectsFromArray:result];
        //[[NSUserDefaults standardUserDefaults] setObject:_conversations forKey:kConversations];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        [_tblConversationList reloadData];
    } failure:^(NSDictionary *result, int status, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not fetch the list of conversations: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
    CatalyzeQuery *queryAuthor = [CatalyzeQuery queryWithClassName:@"conversations"];
    [queryAuthor setPageNumber:1];
    [queryAuthor setPageSize:20];
    [queryAuthor setQueryField:@"authorId"];
    [queryAuthor setQueryValue:[[CatalyzeUser currentUser] usersId]];
    [queryAuthor retrieveInBackgroundWithSuccess:^(NSArray *result) {
        [_conversations addObjectsFromArray:result];
        //[[NSUserDefaults standardUserDefaults] setObject:_conversations forKey:kConversations];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        [_tblConversationList reloadData];
    } failure:^(NSDictionary *result, int status, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not fetch the list of conversations: %@", error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }];
}

- (void)addConversation {
    ContactsViewController *contactsViewController = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    NSMutableArray *currentConversations = [NSMutableArray array];
    for (CatalyzeEntry *entry in _conversations) {
        [currentConversations addObject:[[entry content] valueForKey:@"recipient"]];
        [currentConversations addObject:[[entry content] valueForKey:@"sender"]];
    }
    contactsViewController.currentConversations = currentConversations;
    [self.navigationController pushViewController:contactsViewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ConversationListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationListCellIdentifier"];
    CatalyzeEntry *conversation = [_conversations objectAtIndex:indexPath.row];
    if (![[[conversation content] valueForKey:@"recipient_id"] isEqualToString:[[CatalyzeUser currentUser] usersId]]) {
        [cell setCellData:[[conversation content] valueForKey:@"recipient"]];
    } else {
        [cell setCellData:[[conversation content] valueForKey:@"sender"]];
    }
    [cell setHighlighted:NO animated:NO];
    [cell setSelected:NO animated:NO];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _conversations.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
    ConversationViewController *conversationViewController = [[ConversationViewController alloc] initWithNibName:nil bundle:nil];
    
    NSString *usersId;
    NSString *username;
    CatalyzeEntry *conversation = [_conversations objectAtIndex:indexPath.row];
    if (![[[conversation content] valueForKey:@"recipient_id"] isEqualToString:[[CatalyzeUser currentUser] usersId]]) {
        usersId = [[conversation content] valueForKey:@"recipient_id"];
        username = [[conversation content] valueForKey:@"recipient"];
    } else {
        usersId = [[conversation content] valueForKey:@"sender_id"];
        username = [[conversation content] valueForKey:@"sender"];
    }
    conversationViewController.username = username;
    conversationViewController.userId = usersId;
    conversationViewController.conversationsId = [conversation entryId];
    [self.navigationController pushViewController:conversationViewController animated:YES];
}

@end
