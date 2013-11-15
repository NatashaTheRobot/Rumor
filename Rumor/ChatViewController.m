//
//  ChatViewController.m
//  Rumor
//
//  Created by Natasha Murashev on 11/14/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIView *commentUIView;

@property (strong, nonatomic) NSMutableArray *messages;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.messages = [NSMutableArray array];
}

#pragma mark - Actions

- (IBAction)onSendButtonTap:(id)sender
{
    [self.messages addObject:self.commentTextField.text];
    [self.commentTextField resignFirstResponder];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"message";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    PFUser *friend = self.friends[indexPath.row];
//    cell.textLabel.text = friend[sParseClassUserKeyDisplayName];
//    NSURL *pictureUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=150&height=150", friend[sParseClassUserKeyFacebookId]]];
//    //[cell.imageView setImageWithURL:pictureUrl];
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//    dispatch_async(queue, ^{
//        NSData * imageData = [NSData dataWithContentsOfURL:pictureUrl];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIImage *image = [UIImage imageWithData:imageData];
//            cell.imageView.image = image;
//        });
//    });
    return cell;
}

#pragma mark - Session Delegate

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    
}

- (void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{
    certificateHandler(YES);
}


- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up {
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.commentUIView.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    newFrame.origin.y -= keyboardFrame.size.height * (up?1:-1);
    self.commentUIView.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShown:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    [self moveTextViewForKeyboard:aNotification up:NO];
}


@end
