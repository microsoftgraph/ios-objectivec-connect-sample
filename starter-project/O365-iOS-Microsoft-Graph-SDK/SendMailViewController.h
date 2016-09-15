/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import <UIKit/UIKit.h>
@class MSGraphClient;
@class AuthenticationProvider;

@interface SendMailViewController : UIViewController

@property (strong, nonatomic) AuthenticationProvider *authenticationProvider;

@end
