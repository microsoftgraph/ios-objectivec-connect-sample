/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "ConnectViewController.h"
#import <MSGraphSDK-NXOAuth2Adapter/MSGraphSDKNXOAuth2.h>
#import "AuthenticationConstants.h"
#import "SendMailViewController.h"
#import "AuthenticationProvider.h"

@interface ConnectViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *connectButton;
@property (strong, nonatomic) AuthenticationProvider *authProvider;


@end

@implementation ConnectViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _authProvider = [[AuthenticationProvider alloc]init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

#pragma mark - button interaction (Connect)
- (IBAction)connectTapped:(id)sender {
    [self showLoadingUI:YES];
    
    NSArray *scopes = [kScopes componentsSeparatedByString:@","];
    [self.authProvider connectToGraphWithClientId:kClientId scopes:scopes completion:^(NSError *error) {
        if (!error) {
                        [self performSegueWithIdentifier:@"showSendMail" sender:nil];
                        [self showLoadingUI:NO];
                        NSLog(@"Authentication successful.");
                    }
                    else{
                        NSLog(@"Authentication failed - %@", error.localizedDescription);
                        [self showLoadingUI:NO];
                        
                    };
    }];
}


#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSendMail"]){
        SendMailViewController *sendMailVC = segue.destinationViewController;
        sendMailVC.authenticationProvider =  self.authProvider;
    }
}

#pragma mark - Helper
-(void) showLoadingUI:(BOOL)loading {
    
    if (loading){
        [self.activityIndicator startAnimating];
        [self.connectButton setTitle:@"Connecting..." forState:UIControlStateNormal];
        self.connectButton.enabled = NO;
    }
    
    else{
        
        [self.activityIndicator stopAnimating];
        [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        self.connectButton.enabled = YES;
    }
    
    
}



@end
