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
@property (strong, nonatomic) NSString *pictureWebUrl;
@property (strong, nonatomic) UIImage *userPicture;
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
    
    [self getUserPicture:(self.emailAddress)  completion:^(UIImage *image, NSError *error) {
        
        if (!error) {
            self.userPicture = image;
         
        } else {
            
            //get the test image out of the resources
            self.userPicture = [UIImage imageNamed:(@"test.png")];
        }
        [self uploadPictureToOneDrive:(self.userPicture) completion:^(NSString *webUrl, NSError *error) {
            if (!error) {
                self.pictureWebUrl = webUrl;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(NSLocalizedString(@"ERROR", ""), error.localizedDescription);
                    self.statusTextView.text = NSLocalizedString(@"PICTURE_UPLOAD_FAILURE", comment: "");
                });
                
            }
            
        }];

    }];
    
    
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusTextView.text = NSLocalizedString(@"SEND_SUCCESS", comment: "");
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(NSLocalizedString(@"ERROR", ""), error.localizedDescription);
                self.statusTextView.text = NSLocalizedString(@"SEND_FAILURE", comment: "");
            });
        }
    }];
    
}


#pragma mark - Helper Methods
//Retrieve the logged in user's display name and email address
-(void) getUserInfo {
    [[[self.graphClient me]request]getWithCompletion:^(MSGraphUser *response, NSError *error) {
        if(!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.emailAddress = response.userPrincipalName;
                self.emailTextField.text = self.emailAddress;
                self.headerLabel.text = [NSString stringWithFormat:(NSLocalizedString(@"HI_USER", comment "")), response.displayName];
                self.statusTextView.text =  NSLocalizedString(@"USER_INFO_LOAD_SUCCESS", comment: "");
            });

        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusTextView.text =  NSLocalizedString(@"USER_INFO_LOAD_FAILURE", comment: "");
                NSLog(NSLocalizedString(@"ERROR", ""), error.localizedDescription);
            });
        }
    }];
}

-(void) uploadPictureToOneDrive: (UIImage *) image completion:(void(^) (NSString*, NSError*))completionBlock{
    NSData *data = UIImagePNGRepresentation(image);
    [[[[[[[self.graphClient me]
          drive]
         root]
        children]
       driveItem:(@"me.png")]
      contentRequest]
     uploadFromData:(data) completion:^(MSGraphDriveItem *response, NSError *error) {
         
         if (!error) {
             NSString *webUrl = response.webUrl;
             completionBlock(webUrl, error);
         } else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.statusTextView.text =  NSLocalizedString(@"USER_GET_PICTURE_FAILURE", comment: "");
                 NSLog(NSLocalizedString(@"ERROR", ""), error.localizedDescription);
             });
         }
    }];
}

-(void) getUserPicture: (NSString *)url completion:(void(^) (UIImage*, NSError*))completionBlock {
    [[[self.graphClient me] photoValue] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        //code
        if (!error) {
            NSData *data = [NSData dataWithContentsOfURL:location];
            UIImage *img = [[UIImage alloc] initWithData:data];
                            completionBlock(img, error);
        } else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusTextView.text =  NSLocalizedString(@"USER_GET_PICTURE_FAILURE", comment: "");
                NSLog(NSLocalizedString(@"ERROR", ""), error.localizedDescription);
            });
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
    
    message.subject = NSLocalizedString(@"MAIL_SUBJECT", comment: "");
    
    MSGraphItemBody *emailBody = [[MSGraphItemBody alloc]init];
    NSString *htmlContentPath = [[NSBundle mainBundle] pathForResource:@"EmailBody" ofType:@"html"];
    NSString *htmlContentString = [NSString stringWithContentsOfFile:htmlContentPath encoding:NSUTF8StringEncoding error:nil];
    
    emailBody.content = htmlContentString;
    NSString *replaceString = @"a href=";
    replaceString = [replaceString stringByAppendingString:(self.pictureWebUrl)];
    emailBody.content = [emailBody.content stringByReplacingOccurrencesOfString:(@"a href=%s") withString:(replaceString)];
    emailBody.contentType = [MSGraphBodyType html];
    message.body = emailBody;
    
    message.toRecipients = toRecipients;
    
    MSGraphFileAttachment *fileAttachment= [[MSGraphFileAttachment alloc]init];
    NSData *image =  UIImagePNGRepresentation(self.userPicture);
    fileAttachment.oDataType = @"#microsoft.graph.fileAttachment";
    fileAttachment.contentType = @"image/png";
    
    NSString *decodedString = [[NSString alloc] initWithData:image encoding:NSUTF8StringEncoding];
    
    fileAttachment.contentBytes = decodedString;
    fileAttachment.name = @"me.png";
    message.attachments = [message.attachments arrayByAddingObject:(fileAttachment)];
    return message;
    
}


@end
