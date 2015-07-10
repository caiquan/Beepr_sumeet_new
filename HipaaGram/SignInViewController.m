
/**
 SigninViewController.m
 */
#import "SignInViewController.h"
#import "Catalyze.h"
#import "AppConstant.h"
#import "SVProgressHUD.h"
#import "CatalyzeHTTPManager.h"
#import "Catalyze.h"
#import "ProgressHUD.h"
#import "common.h"
#import <UbertestersSDK/Ubertesters.h>

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtLastText;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstName;

@end

@implementation SignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self enableRegistration];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)enableRegistration {
    _btnRegister.alpha = 1.0f;
    _btnRegister.userInteractionEnabled = YES;
    
    _lblSignUpTitle.alpha = 1.0f;
    _lblSignUpTitle.userInteractionEnabled = YES;
    
    [_btnSignIn setTitleColor:_btnSignIn.backgroundColor forState:UIControlStateNormal];
    _btnSignIn.backgroundColor = [UIColor whiteColor];
    
    [UIView animateWithDuration:0.3 animations:^{
        _txtPhoneNumber.placeholder = @"email";
        
        _txtPhoneNumber.alpha = 1.0f;
        _txtPhoneNumber.userInteractionEnabled = YES;
        _txtPhoneNumber.text = @"";
        _txtPassword.text = @"";
        
        _txtFirstName.alpha = 1.0f;
        _txtFirstName.userInteractionEnabled = YES;
        
        _txtLastText.alpha = 1.0f;
        _txtLastText.userInteractionEnabled = YES;
        
        CGRect frame = _btnSignIn.frame;
        frame.origin.y = _btnRegister.frame.origin.y + _btnRegister.frame.size.height + 8;
        [_btnSignIn setFrame:frame];
        
        frame = _lblSignInTitle.frame;
        frame.origin.y = _lblSignInTitle.frame.origin.y - _lblSignInTitle.frame.size.height - 5;
        [_lblSignInTitle setFrame:frame];

    }];
}

- (void)disableRegistration {
    [UIView animateWithDuration:0.3 animations:^{

        _txtFirstName.alpha = 0.0f;
        _txtFirstName.userInteractionEnabled = NO;

        _txtLastText.alpha = 0.0f;
        _txtLastText.userInteractionEnabled = NO;

        _lblSignUpTitle.alpha = 0.0f;
        _lblSignUpTitle.userInteractionEnabled = NO;

        CGRect frame = _btnSignIn.frame;
        frame.origin.y = _btnRegister.frame.origin.y;
        [_btnSignIn setFrame:frame];
        
    } completion:^(BOOL finished) {
        _btnRegister.alpha = 0.0f;
        _btnRegister.userInteractionEnabled = NO;
        
        _lblSignInTitle.alpha = 1.0f;
        _lblSignUpTitle.userInteractionEnabled = YES;
        
        _btnSignIn.backgroundColor = [_btnSignIn titleColorForState:UIControlStateNormal];
        [_btnSignIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _lblSignInTitle.frame;
            frame.origin.y = _lblSignUpTitle.frame.origin.y;
            [_lblSignInTitle setFrame:frame];
        }];
    }];
}

- (IBAction)signIn:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                    message:@"Please fill out blank."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    UIAlertView *alertEmail = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                         message:@"Invalid Email format."
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
    
    if(_btnSignIn.backgroundColor == [UIColor whiteColor]){
        [self disableRegistration];
        return;
    }
    if (_btnRegister.alpha == 1.0f) {
            [self disableRegistration];
    }
    
    if (_txtPassword.text.length == 0 || _txtPhoneNumber.text.length == 0) {
        [alert show];
        return;
    }
    
    if(![self NSStringIsValidEmail:_txtPhoneNumber.text]){
        [alertEmail show];
        return;
    }
    
    
    [SVProgressHUD showWithStatus:@"Signing In..." maskType:SVProgressHUDMaskTypeGradient];
    [CatalyzeUser logInWithUsernameInBackground:[self getNameFromEmail:_txtPhoneNumber.text]
                                       password:_txtPassword.text
                                        success:^(CatalyzeUser *user) {

                                            CatalyzeQuery *query = [CatalyzeQuery queryWithClassName:PF_USER_CLASS_NAME];
                                            [query setQueryField:PF_USER_OBJECTID];
                                            [query setQueryValue:user.usersId];
                                            [query setPageNumber:1];
                                            [query setPageSize:20];
                                            [query retrieveInBackgroundWithSuccess:^(NSArray* result){
                                                [SVProgressHUD dismiss];
                                                
                                                if(result.count == 0)
                                                    [self addToContactsNew:user];
                                                
                                                [self dismissViewControllerAnimated:YES completion:nil];
                                                
                                                [UAirship push].alias = [[NSUserDefaults standardUserDefaults] valueForKey:kUserUsername];
                                                [[UAirship push] updateRegistration];
                                                
                                                PostNotification(NOTIFICATION_USER_LOGGED_IN);
                                                [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", [[CatalyzeUser currentUser] username]]];
                                                
                                            } failure:^(NSDictionary *result, int status, NSError * error){
                                                [SVProgressHUD dismiss];
                                            }];

                                        } failure:^(NSDictionary *result, int status, NSError *error) {
                                            [SVProgressHUD showErrorWithStatus:@"Invalid username / password"];
                                            
                                            if (status == 404) {
                                                [self enableRegistration];
                                            }
                                        }];

}

#pragma UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    _txtPhoneNumber.text = @"";
}

#pragma mark - set user as supervisor
- (void) setSupervisorWithName:(NSString *) name{
    NSDictionary *body = @{};
    NSString *url = [NSString stringWithFormat:@"/app/supervisor/%@",name];
    [CatalyzeHTTPManager doPost:url withParams:body success:^(id result) {
        NSLog(@"success user setting as supervisor");
    } failure:^(NSDictionary *result, int status, NSError *error){
        NSLog(@"faile user setting as supervisor");
    }];
}

- (IBAction)registerUser:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                    message:@"Please fill out blank."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
    UIAlertView *alertEmail = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                    message:@"Invalid Email format."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];


    if (_txtPhoneNumber.text.length == 0 || _txtPassword.text.length == 0 || _txtFirstName.text.length == 0|| _txtLastText.text.length == 0 ) {
        [alert show];
        return;
    }else if(![self NSStringIsValidEmail:_txtPhoneNumber.text]){
        [alertEmail show];
        return;
    }
    
    Email *email = [[Email alloc] init];
    email.primary = _txtPhoneNumber.text;
    email.work = _txtPhoneNumber.text;
    Name *name = [[Name alloc] init];
    name.firstName = _txtFirstName.text;
    name.lastName = _txtLastText.text;

    [SVProgressHUD showWithStatus:@"Signing Up..." maskType:SVProgressHUDMaskTypeGradient];
    [CatalyzeUser signUpWithUsernameInBackground:[self getNameFromEmail:_txtPhoneNumber.text]
                                           email:email
                                            name:name
                                        password:_txtPassword.text
                                         success:^(CatalyzeUser *result) {
                                             [SVProgressHUD dismiss];
                                             [[NSUserDefaults standardUserDefaults] setValue:[result usersId] forKey:@"usersId"];
                                             [[NSUserDefaults standardUserDefaults] setValue:email.primary forKey:kUserEmail];
                                             [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@ %@", name.firstName, name.lastName] forKey:kUserUsername];
                                             [[NSUserDefaults standardUserDefaults] synchronize];
        
                                             [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Please activate your account and then sign in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                                             [self disableRegistration];
                                         } failure:^(NSDictionary *result, int status, NSError *error) {
                                             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (NSString *) getNameFromEmail:(NSString *)email{
    NSRange range = [email rangeOfString:@"@"];
    return [email substringToIndex:range.location];
}

- (void)addToContacts:(NSString *)username usersId:(NSString *)usersId {
    CatalyzeEntry *contact = [CatalyzeEntry entryWithClassName:PF_USER_CLASS_NAME];
    
    [[contact content] setValue:username forKey:PF_USER_FULLNAME];
    [[contact content] setValue:usersId forKey:PF_USER_OBJECTID];
    
    [contact createInBackgroundWithSuccess:^(id result) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"added_to_contacts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSDictionary *result, int status, NSError *error) {
        NSLog(@"Was not added to the contacts custom class!");
    }];
}

- (void)addToContactsNew:(CatalyzeUser *)user{
    CatalyzeEntry *contact = [CatalyzeEntry entryWithClassName:PF_USER_CLASS_NAME];
    
    [[contact content] setValue:[NSString stringWithFormat:@"%@ %@",user.name.firstName, user.name.lastName] forKey:PF_USER_FULLNAME];
    [[contact content] setValue:user.usersId forKey:PF_USER_OBJECTID];
    [[contact content] setValue:user.email.primary forKey:PF_USER_EMAIL];
    [[contact content] setValue:user.email.primary forKey:PF_USER_EMAILCOPY];
    
    [contact createInBackgroundWithSuccess:^(id result) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"added_to_contacts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSDictionary *result, int status, NSError *error) {
        NSLog(@"Was not added to the contacts custom class!");
    }];
    
//    [self setSupervisorWithName:user.username];
}

- (NSString *)randomEmail {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:10];
    
    for (int i=0; i<10; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
//    return [NSString stringWithFormat:@"josh+%@@catalyze.io", randomString];
    return [NSString stringWithFormat:@"sumeet+%@@beerp.com", randomString];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
