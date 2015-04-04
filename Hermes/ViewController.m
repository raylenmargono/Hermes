//
//  ViewController.m
//  Hermes
//
//  Created by Raylen Margono on 3/20/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [projectColor returnColor];
}

-(void)dismissKeyboard {
    [self.passwordField resignFirstResponder];
    [self.usernameField resignFirstResponder];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [PFUser logInWithUsernameInBackground:self.usernameField.text password:self.passwordField.text block:
     ^(PFUser *user, NSError *error) {
         if (!error) {
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"mapView"];
             UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:viewController];
             [self presentViewController:nav animated:YES completion:^{
                 NSLog(@"success");
             }];

         }else{
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ooops!" message:[NSString stringWithFormat:@"Oops: %@",error.localizedDescription]  delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil];
             [alert show];
         }
     }];
}
- (IBAction)signup:(id)sender {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:self.usernameField.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (objects.count==0) {
            if (self.usernameField.text.length>5 && self.passwordField.text.length>5 ) {
                [self performSegueWithIdentifier:@"userLoginSegue" sender:self];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ooops!" message:@"Choose another name: username and passwords needs to be longer than 5 characters"  delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil];
                [alert show];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Ooops!" message:@"Choose another name: username taken"  delegate:self cancelButtonTitle:@"Ok!" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    registrationView *vc = [segue destinationViewController];
    vc.username = self.usernameField.text;
    vc.password = self.passwordField.text;

}
@end
