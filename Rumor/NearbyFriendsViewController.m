//
//  NearbyFriendsViewController.m
//  Rumor
//
//  Created by Natasha Murashev on 11/14/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "NearbyFriendsViewController.h"
#import "ChatViewController.h"

typedef void (^InvitationHandler)(BOOL accept, MCSession *session);

@interface NearbyFriendsViewController () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, UIAlertViewDelegate, PFLogInViewControllerDelegate>

@property (strong, nonatomic) PFLogInViewController *loginViewController;
@property (strong, nonatomic) MCNearbyServiceBrowser *browser;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCSession *session;
@property (assign, nonatomic) InvitationHandler invitationHandler;

@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation NearbyFriendsViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.loginViewController = [[PFLogInViewController alloc] init];
    [self.loginViewController setDelegate:self];
    [self.loginViewController setFields:
     PFLogInFieldsFacebook
     ];
    [self.loginViewController setFacebookPermissions:@[@"email"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) {
        [self presentViewController:self.loginViewController animated:NO completion:nil];
    } else {
        [self advertisePeer];
        [self browseForPeers];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChatViewController *chatViewController = (ChatViewController *)segue.destinationViewController;
    self.session.delegate = chatViewController;
}

#pragma mark - Actions

- (IBAction)onChatButtonTap:(id)sender
{
    // do this in the Chat View Controller!!!
    // segue to chat view controller - make chat view controller the session delegate.
    [self.friends enumerateObjectsUsingBlock:^(MCPeerID *peerId, NSUInteger idx, BOOL *stop) {
        self.session = [[MCSession alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name]];
        [self.browser invitePeer:peerId toSession:self.session withContext:nil timeout:60];
        
    }];
}

#pragma mark - PFLoginViewControllerDelegate
-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    BOOL newUser = [user isNew];
    if (!newUser) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
        if (!error) {
            
            if (user[@"name"]) {
                [PFUser currentUser][@"displayName"] = user[@"name"];
            }
            
            if (user.id && user.id != 0) {
                [PFUser currentUser][@"facebookId"] = user[@"id"];
            }
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (newUser) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self advertisePeer];
                    [self browseForPeers];
                }
            }];
        } else {
            NSLog(@"Error getting user info");
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    PFUser *friend = self.friends[indexPath.row];
    cell.textLabel.text = friend[sParseClassUserKeyDisplayName];
    
//    cell.imageView.image = // PUT IN IMAGE HERE
    
    return cell;
}

#pragma mark - Advertise

- (void)advertisePeer
{
    PFUser *user = [PFUser currentUser];
    if (user) {
        MCPeerID *advertiserPeerId = [[MCPeerID alloc] initWithDisplayName:user.objectId];
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:advertiserPeerId discoveryInfo:nil serviceType:@"rumor-chat"];
        self.advertiser.delegate = self;
        [self.advertiser startAdvertisingPeer];
    }
}

#pragma mark - Browse For Peers

- (void)browseForPeers
{
    PFUser *user = [PFUser currentUser];
    MCPeerID *browserId = [[MCPeerID alloc] initWithDisplayName:user.objectId];
    self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:browserId serviceType:@"rumor-chat"];
    self.browser.delegate = self;
    [self.browser startBrowsingForPeers];
}

#pragma mark - MCNearbyAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
       withContext:(NSData *)context
 invitationHandler:(void (^)(BOOL accept, MCSession *session))invitationHandler
{
    PFUser *browsingUser = [PFQuery getUserObjectWithId:peerID.displayName];
    
    PFUser *user = [PFUser currentUser];
    self.invitationHandler = invitationHandler;
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"%@, You're Invited!", user[sParseClassUserKeyDisplayName]]
                              message:[NSString stringWithFormat:@"%@ invited you to chat", browsingUser[sParseClassUserKeyDisplayName]]
                              delegate:self cancelButtonTitle:@"Decline"
                              otherButtonTitles:@"Accept", nil];
    [alertView show];
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL accept = buttonIndex == alertView.cancelButtonIndex ? NO : YES;
    self.session = [[MCSession alloc] initWithPeer:[[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name]];
    self.invitationHandler(accept, self.session);
}

#pragma mark - MCNearbyBrowerDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    PFUser *peer = [PFQuery getUserObjectWithId:peerID.displayName];
    
    // Check if peer is a facebook Friend!
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"objectId = %@", peer.objectId];
    NSArray *foundFriends = [self.friends filteredArrayUsingPredicate:filter];
    if (foundFriends.count == 0) {
        [self.friends addObject:peer];
        [self.tableView reloadData];
    }
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    PFUser *peer = [PFQuery getUserObjectWithId:peerID.displayName];
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"objectId = %@", peer.objectId];
    NSArray *foundFriends = [self.friends filteredArrayUsingPredicate:filter];
    if (foundFriends.count > 0) {
        PFUser *peerToRemove = foundFriends[0];
        [self.friends removeObject:peerToRemove];
        [self.tableView reloadData];
    }
    [self browseForPeers];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    
}

#pragma mark - Getter / Setter Overrides

- (NSMutableArray *)friends
{
    if (!_friends) {
        self.friends = [NSMutableArray arrayWithCapacity:10];
    }
    return _friends;
}

@end
