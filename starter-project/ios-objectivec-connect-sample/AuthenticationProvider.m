/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

#import "AuthenticationProvider.h"
#import "AuthenticationConstants.h"
#import <MSGraphSDK-NXOAuth2Adapter/MSGraphSDKNXOAuth2.h>

@implementation AuthenticationProvider

- (NXOAuth2AuthenticationProvider *)authProvider {
    return [NXOAuth2AuthenticationProvider sharedAuthProvider];
}


/**
 Signs out the current AuthProvider, completely removing all tokens and cookies.
 @param completionHandler The completion handler to be called when sign out has completed.
 error should be non nil if there was no error, and should contain any error(s) that occurred.
 */
-(void) disconnect{
    [self.authProvider logout];
}

@end
