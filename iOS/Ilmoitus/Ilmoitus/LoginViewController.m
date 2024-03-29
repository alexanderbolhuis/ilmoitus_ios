//
//  LoginViewController.m
//  Ilmoitus
//
//  Created by Alexander Bolhuis on 22-04-14.
//  Copyright (c) 2014 42IN12EWa. All rights reserved.
//

#import "LoginViewController.h"
#import "constants.h"
#import "HttpResponseHandler.h"
#import "DejalActivityView.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernamefield;
@property (weak, nonatomic) IBOutlet UITextField *passwordfield;
@property (nonatomic, strong) UIAlertView *loginFailedAlert;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.usernamefield.delegate = self;
    self.passwordfield.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
    // Logout
    if (self.tabBarController != nil) {
        [self logout];
    }
    
}

-(void)logout
{
    AFHTTPRequestOperationManager *manager = [HttpResponseHandler createNewHttpRequestOperationManager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [NSString stringWithFormat:@"%@/auth/logout", baseURL];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions
                              error:&error];
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        
        NSLog(@"%@", json);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [HttpResponseHandler handelErrorCode:operation :error:self];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (IBAction)loginAction:(id)sender {
    [DejalBezelActivityView activityViewForView:self.view];
    AFHTTPRequestOperationManager *manager = [HttpResponseHandler createNewHttpRequestOperationManager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSDictionary *params = @{@"email":self.usernamefield.text, @"password":self.passwordfield.text};
    NSString *url = [NSString stringWithFormat:@"%@/auth/login", baseURL];
    AFHTTPRequestOperation *apiRequest = [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseObject
                              
                              options:kNilOptions
                              error:&error];
        
        NSLog(@"JSON: %@",json);
        NSNumber *success = json[@"is_logged_in"];
        // Check if is_logged_in is true
        if ([success boolValue]) {
            // Put Token in UserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:json[@"person_id"] forKey:@"person_id"];
            [[NSUserDefaults standardUserDefaults] setObject:json[@"token"] forKey:@"token"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // GET Usersettings
            AFHTTPRequestOperationManager *manager = [HttpResponseHandler createNewHttpRequestOperationManager];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            
            [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
            
            [manager.requestSerializer setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"] forHTTPHeaderField:@"Authorization"];
            
            NSString *url = [NSString stringWithFormat:@"%@/current_user/details", baseURL];
            [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSError* error;
                NSDictionary* json = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      
                                      options:kNilOptions
                                      error:&error];
                
                [[NSUserDefaults standardUserDefaults] setObject:json[@"first_name"] forKey:@"person_first_name"];
                [[NSUserDefaults standardUserDefaults] setObject:json[@"last_name"] forKey:@"person_last_name"];
                [[NSUserDefaults standardUserDefaults] setObject:json[@"employee_number"] forKey:@"person_employee_number"];
                [[NSUserDefaults standardUserDefaults] setObject:json[@"email"] forKey:@"person_email"];
                [[NSUserDefaults standardUserDefaults] setObject:json[@"supervisor"] forKey:@"supervisor"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Perform Segue
                [DejalBezelActivityView removeViewAnimated:YES];
                [self performSegueWithIdentifier:@"login_success" sender:self];
                
                NSLog(@"%@", json);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", responseObject);
                [DejalBezelActivityView removeViewAnimated:YES];
                [HttpResponseHandler handelErrorCode:operation :error:self];
            }];
        } else {
            NSLog(@"JSON: %@",@"Failed");
            [DejalBezelActivityView removeViewAnimated:YES];
            [HttpResponseHandler showErrorMessageTitle:@"Error" Message:@"Login mislukt"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [DejalBezelActivityView removeViewAnimated:YES];
        [HttpResponseHandler showErrorMessageTitle:@"Error" Message:@"Login mislukt"];
    }];
    
    [apiRequest start];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
