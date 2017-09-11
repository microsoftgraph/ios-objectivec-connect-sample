/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "SendMailViewController.h"
#import <MSGraphSDK/MSGraphSDK.h>
#import "ConnectViewController.h"
#import "AuthenticationProvider.h"


@interface SendMailViewController() <NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UITextView *statusTextView;
@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UIButton *sendMailButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *emailAddress;
@property (strong, nonatomic) MSGraphClient *graphClient;
@property (strong, nonatomic) IBOutlet UINavigationItem *appTitle;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *disconnectButton;
@property (strong, nonatomic) IBOutlet UITextView *descriptionLabel;

@end



@implementation SendMailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =  NSLocalizedString(@"GRAPH_TITLE", comment: "");
    self.disconnectButton.title = NSLocalizedString(@"DISCONNECT", comment: "");
    self.descriptionLabel.text = NSLocalizedString(@"DESCRIPTION", comment: "");
    [self.sendMailButton setTitle:(NSLocalizedString(@"SEND", comment: "")) forState:normal];
    
    [MSGraphClient setAuthenticationProvider:self.authenticationProvider.authProvider];
    self.graphClient = [MSGraphClient client];
    [self getUserInfo];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationItem setHidesBackButton:YES];
    
}

- (IBAction)sendMailTapped:(id)sender {
    [self sendMail];
}

- (IBAction)disconnectTapped:(id)sender {
    [self.authenticationProvider disconnect];
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Helper Methods
//Retrieve the logged in user's display name and email address
-(void) getUserInfo: (NSString *)url completion:(void(^) ( NSError*))completionBlock{
    
    [[[self.graphClient me]request]getWithCompletion:^(MSGraphUser *response, NSError *error) {
        if(!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.emailAddress = response.userPrincipalName;
                self.emailTextField.text = self.emailAddress;
                self.headerLabel.text = [NSString stringWithFormat:(NSLocalizedString(@"HI_USER", comment "")), response.displayName];
                self.statusTextView.text =  NSLocalizedString(@"USER_INFO_LOAD_SUCCESS", comment: "");
            });
            
            completionBlock(nil);
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusTextView.text =  NSLocalizedString(@"USER_INFO_LOAD_FAILURE", comment: "");
                NSLog(NSLocalizedString(@"ERROR", ""), error.localizedDescription);
            });
            completionBlock(error);
        }
    }];
    
}


@end
