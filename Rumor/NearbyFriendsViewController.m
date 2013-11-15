//
//  NearbyFriendsViewController.m
//  Rumor
//
//  Created by Natasha Murashev on 11/14/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "NearbyFriendsViewController.h"

@interface NearbyFriendsViewController () <PFLogInViewControllerDelegate>

@property (strong, nonatomic) PFLogInViewController *loginViewController;

@end

@implementation NearbyFriendsViewController 

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (![PFUser currentUser]) {
        [self presentViewController:self.loginViewController animated:NO completion:nil];
    }
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
                }
            }];
        } else {
            NSLog(@"Error getting user info");
        }
    }];
}


@end
