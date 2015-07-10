/*
 * Copyright (C) 2014 Catalyze, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"


@protocol SignInDelegate <NSObject>

- (void)signInSuccessful;

@end

@interface SignInViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) id<SignInDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lblSignUpTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnRegister;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;


@property (weak, nonatomic) IBOutlet UILabel *lblSignInTitle;
- (IBAction)signIn:(id)sender;
- (IBAction)registerUser:(id)sender;

@end
