//
//  ChatViewController.h
//  Rumor
//
//  Created by Natasha Murashev on 11/14/13.
//  Copyright (c) 2013 NatashaTheRobot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UIViewController <MCSessionDelegate>

@property (strong, nonatomic) MCSession *session;

@end
