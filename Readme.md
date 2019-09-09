---
page_type: sample
products:
- office-365 
- ms-graph
languages:
- objc
extensions:
  contentType: samples
  technologies:
  - Microsoft Graph
  - Microsoft identity platform
  services:
  - Office 365
  - Microsoft identity platform
  - Users
  platforms:
  - iOS
  createdDate: 5/12/2016 8:22:39 AM
---
# Office 365 Connect Sample for iOS Using the Microsoft Graph SDK

Microsoft Graph is a unified endpoint for accessing data, relationships and insights that come from the Microsoft Cloud. This sample shows how to connect and authenticate to it, and then call mail and user APIs through the [Microsoft Graph SDK for iOS](https://github.com/microsoftgraph/msgraph-sdk-ios).

> Note: Try out the [Microsoft Graph App Registration Portal](https://apps.dev.microsoft.com) page which simplifies registration so you can get this sample running faster.

## Prerequisites
* Download [Xcode](https://developer.apple.com/xcode/downloads/) from Apple.

* Installation of [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)  as a dependency manager.
* A Microsoft work or personal email account such as Office 365, or outlook.com, hotmail.com, etc. You can sign up for [an Office 365 Developer subscription](https://aka.ms/devprogramsignup) that includes the resources that you need to start building Office 365 apps.

     > Note: If you already have a subscription, the previous link sends you to a page with the message *Sorry, you can’t add that to your current account*. In that case, use an account from your current Office 365 subscription.    
* A client id from the registered app at [Microsoft Graph App Registration Portal](https://apps.dev.microsoft.com)
* To make requests, an **MSAuthenticationProvider** must be provided which is capable of authenticating HTTPS requests with an appropriate OAuth 2.0 bearer token. We will be using [msgraph-sdk-ios-nxoauth2-adapter](https://github.com/microsoftgraph/msgraph-sdk-ios-nxoauth2-adapter) for a sample implementation of MSAuthenticationProvider that can be used to jump-start your project. See the below section **Code of Interest** for more information.


## Running this sample in Xcode

1. Clone this repository
2. If it is not already installed, run the following commands from the **Terminal** app to install and set up the CocoaPods dependency manager.

		sudo gem install cocoapods
	
		pod setup

2. Use CocoaPods to import the Microsoft Graph SDK and authentication dependencies:

		pod 'MSGraphSDK'
		pod 'MSGraphSDK-NXOAuth2Adapter'


 This sample app already contains a podfile that will get the pods into  the project. Simply navigate to the project root where the podfile is and from **Terminal** run:

        pod install

   For more information, see **Using CocoaPods** in [Additional Resources](#AdditionalResources)

3. Open **ios-objectivec-sample.xcworkspace**
4. Open **AuthenticationConstants.m**. You'll see that the **ClientID** from the registration process can be added to the top of the file.:

   ```objectivec
        // You will set your application's clientId
        NSString * const kClientId    = @"ENTER_YOUR_CLIENT_ID";
   ```


    You'll notice that the following permission scopes have been configured for this project: 

```@"https://graph.microsoft.com/User.Read, https://graph.microsoft.com/Mail.ReadWrite, https://graph.microsoft.com/Mail.Send, https://graph.microsoft.com/Files.ReadWrite"```
    

    
>Note: The service calls used in this project, sending a mail to your mail account, uploading a picture to OneDrive, and retrieving some profile information (Display Name, Email Address, profile picture) require these permissions for the app to run properly.

5. Run the sample. You'll be asked to connect/authenticate to a work or personal mail account, and then you can send a mail to that account, or to another selected email account.


## Code of Interest

All authentication code can be viewed in the **AuthenticationProvider.m** file. We use a sample implementation of MSAuthenticationProvider extended from [NXOAuth2Client](https://github.com/nxtbgthng/OAuth2Client) to provide login support for registered native apps, automatic refreshing of access tokens, and logout functionality:

```objectivec

		[[NXOAuth2AuthenticationProvider sharedAuthProvider] loginWithViewController:nil completion:^(NSError *error) {
    		if (!error) {
        	[MSGraphClient setAuthenticationProvider:[NXOAuth2AuthenticationProvider sharedAuthProvider]];
        	self.client = [MSGraphClient client];
   			 }
		}];
```

Once the authentication provider is set, we can create and initialize a client object (MSGraphClient) that will be used to make calls against the Microsoft Graph service endpoint (mail and users). In **SendMailViewcontroller.m** we can get the user profile picture, upload it to OneDrive, assemble a mail request with picture attachment and send it using the following code:

### Get the user's profile picture

```objectivec
[[[self.graphClient me] photoValue] downloadWithCompletion:^(NSURL *location, NSURLResponse *response, NSError *error) {
        //code
        if (!error) {
            NSData *data = [NSData dataWithContentsOfURL:location];
            UIImage *img = [[UIImage alloc] initWithData:data];
                            completionBlock(img, error);
        } 
    }];
```
### Upload the picture to OneDrive

```objectivec
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
         } 
    }];

```
### Add picture attachment to a new email message

```objectivec
   MSGraphFileAttachment *fileAttachment= [[MSGraphFileAttachment alloc]init];
    fileAttachment.oDataType = @"#microsoft.graph.fileAttachment";
    fileAttachment.contentType = @"image/png";
    
    NSString *decodedString = [UIImagePNGRepresentation(self.userPicture) base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    
    fileAttachment.contentBytes = decodedString;
    fileAttachment.name = @"me.png";
    message.attachments = [message.attachments arrayByAddingObject:(fileAttachment)];
```

### Send the mail message

```objectivec
    MSGraphUserSendMailRequestBuilder *requestBuilder = [[self.client me]sendMailWithMessage:message saveToSentItems:true];    
    MSGraphUserSendMailRequest *mailRequest = [requestBuilder request];   
    [mailRequest executeWithCompletion:^(NSDictionary *response, NSError *error) {      
    }];
```

For more information, including code to call into other services like OneDrive, see the [Microsoft Graph SDK for iOS](https://github.com/microsoftgraph/msgraph-sdk-ios)

## Questions and comments

We'd love to get your feedback about the Office 365 iOS Microsoft Graph Connect project. You can send your questions and suggestions to us in the [Issues](https://github.com/microsoftgraph/iOS-objectivec-connect-sample/issues) section of this repository.

Questions about Office 365 development in general should be posted to [Stack Overflow](http://stackoverflow.com/questions/tagged/Office365+API). Make sure that your questions or comments are tagged with [Office365] and [MicrosoftGraph].

## Contributing
You will need to sign a [Contributor License Agreement](https://cla.microsoft.com/) before submitting your pull request. To complete the Contributor License Agreement (CLA), you will need to submit a request via the form and then electronically sign the CLA when you receive the email containing the link to the document.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Additional resources

* [Office Dev Center](http://dev.office.com/)
* [Microsoft Graph overview page](https://graph.microsoft.io)
* [Using CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

## Copyright
Copyright (c) 2016 Microsoft. All rights reserved.
