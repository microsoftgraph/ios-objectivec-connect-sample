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


@end



@implementation SendMailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
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


//Send mail to the specified user in the email text field
-(void) sendMail {
    
    MSGraphMessage *message = [self getSampleMessage];
    MSGraphUserSendMailRequestBuilder *requestBuilder = [[self.graphClient me]sendMailWithMessage:message saveToSentItems:true];
    NSLog(@"%@", requestBuilder);
    MSGraphUserSendMailRequest *mailRequest = [requestBuilder request];
    [mailRequest executeWithCompletion:^(NSDictionary *response, NSError *error) {
        if(!error){
            NSLog(@"response %@", response);
            NSLog(@"error %@", error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusTextView.text = @"Check your inbox, you have a new message. :)";
            });
        }
        else {
            NSLog(@"Error sending mail - %@", error.localizedDescription);
            self.statusTextView.text = @"The email could not be sent. Check the log for errors.";
        }
    }];
    
}


#pragma mark - Helper Methods
//Retrieve the logged in user's display name and email address
-(void) getUserInfo {
    [[[self.graphClient me]request]getWithCompletion:^(MSGraphUser *response, NSError *error) {
        if(!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.emailAddress = response.mail;
                self.emailTextField.text = self.emailAddress;
                self.headerLabel.text = [NSString stringWithFormat:@"Hi %@!", response.displayName];
            });

        }
        else{
            self.statusTextView.text = @"Unable to retrieve user account information, see log for more details.";
            NSLog(@"Retrieval of user account information failed - %@", error.localizedDescription);
        }
    }];
}

//Create a sample test message to send to specified user account
-(MSGraphMessage*) getSampleMessage{
    MSGraphMessage *message = [[MSGraphMessage alloc]init];
    MSGraphRecipient *toRecipient = [[MSGraphRecipient alloc]init];
    MSGraphEmailAddress *email = [[MSGraphEmailAddress alloc]init];
    
    email.address = self.emailAddress;
    toRecipient.emailAddress = email;
    
    NSMutableArray *toRecipients = [[NSMutableArray alloc]init];
    [toRecipients addObject:toRecipient];
    
    message.subject = @"Mail received from the Office 365 iOS Microsoft Graph SDK Sample";
    
    MSGraphItemBody *emailBody = [[MSGraphItemBody alloc]init];
    NSString *htmlContentPath = [[NSBundle mainBundle] pathForResource:@"EmailBody" ofType:@"html"];
    NSString *htmlContentString = [NSString stringWithContentsOfFile:htmlContentPath encoding:NSUTF8StringEncoding error:nil];
    
    emailBody.content = htmlContentString;
    emailBody.contentType = [MSGraphBodyType html];
    message.body = emailBody;
    
    message.toRecipients = toRecipients;
    
    return message;
    
}


@end
