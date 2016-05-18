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


-(void)connectToGraphWithClientId:(NSString *)clientId scopes:(NSArray *)scopes completion:(void (^)(NSError *))completion{
    [NXOAuth2AuthenticationProvider setClientId:kClientId
                                              scopes:scopes];
    
    
    /**
     Obtains access token by performing login with UI, where viewController specifies the parent view controller.
     @param viewController The view controller to present the UI on.
     @param completionHandler The completion handler to be called when the authentication has completed.
     error should be non nil if there was no error, and should contain any error(s) that occurred.
     */
    if ([[NXOAuth2AuthenticationProvider sharedAuthProvider] loginSilent]) {
        completion(nil);
    }
    else{
        [[NXOAuth2AuthenticationProvider sharedAuthProvider] loginWithViewController:nil completion:^(NSError *error) {
            if (!error) {
                NSLog(@"Authentication sucessful.");
                completion(nil);
            }
            else{
                NSLog(@"Authentication failed - %@", error.localizedDescription);
                completion(error);
            }
        }];
    }
    
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
