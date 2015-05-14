//
//  ViewController.m
//  AutoLayoutAnimations
//
//  Created by admin on 19/04/15.
//  Copyright (c) 2015 corsarus. All rights reserved.
//

#import "ViewController.h"
#import "PopupView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)showMessage:(id)sender
{
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.numberOfLines = 0;
    messageLabel.text = @"You see? It's curious. Ted did figure it out - time travel. And when we get back, we gonna tell everyone. How it's possible, how it's done, what the dangers are.";
    
    PopupView *popupView = [[PopupView alloc] initWithContentView:messageLabel];
    [popupView showInView:self.view];
}



@end
