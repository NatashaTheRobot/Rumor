//
//  LoginViewController.m
//  Rumor
//
//  Created by Admin on 11/14/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController () <PFLogInViewControllerDelegate>

@property (strong, nonatomic) PFLogInViewController *loginViewController;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.loginViewController = [[PFLogInViewController alloc] init];
        [self.loginViewController setDelegate:self];
        [self.loginViewController setFields:
         PFLogInFieldsFacebook
         ];
        [self.loginViewController setFacebookPermissions:@[@"email"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
