//
//  ViewController.m
//  DropInPayPal
//
//  Created by MTS Dublin on 14/06/2017.
//  Copyright © 2017 BraintreeEMEA. All rights reserved.
//

#import "ViewController.h"
#import "BraintreeCore.h"
#import "BraintreeDropIn.h"
#import "BraintreePayPal.h"

@interface ViewController ()

@end

@implementation ViewController

NSString *myTokenizationKey;
NSString *resultCheck;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
// Using tokenization key. If you want to use a feature like 3D Secure, please use client-token instead
myTokenizationKey = @"sandbox_tpt8mgp5_26qns4ycnjgrr6cv";
    
    
}


- (IBAction)launchDropIn:(id)sender {
    BTDropInRequest *request = [[BTDropInRequest alloc] init];
    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:myTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"ERROR");
        } else if (result.cancelled) {
            NSLog(@"CANCELLED");
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
            // Use the BTDropInResult properties to update your UI
            // result.paymentOptionType
            // result.paymentMethod
            // result.paymentIcon
            // result.paymentDescription
            
            // or send the nonce to your server-side integration to create a transaction
            [self postNonceToServer:result.paymentMethod.nonce];
            
            
        }
    }];
    [self presentViewController:dropIn animated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    
    // It is not recommended to send the amount from client-side in production due to security reasons, so you should implement your own logic for passing the amount on the server-side
    double price = 12.99;
    
    
    NSLog(@"%@",paymentMethodNonce);
    NSURL *paymentURL = [NSURL URLWithString:@"http://orcodevbox.co.uk/BTOrcun/iosPayment.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:paymentURL];
    
    request.HTTPBody = [[NSString stringWithFormat:@"amount=%ld&payment_method_nonce=%@", (long)price,paymentMethodNonce] dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *paymentResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // TODO: Handle success and failure
        
        // Logging the HTTP request so we can see what is being sent to the server side
        NSLog(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
        
        
        // Log the transaction result
        NSLog(@"%@",paymentResult);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Checking the result for the string "Successful" and updating GUI elements
            if ([paymentResult containsString:@"Successful"]) {
                NSLog(@"Transaction is successful!");
                resultCheck = @"Transaction successful";
                
                
            } else {
                NSLog(@"Transaction failed!");
                resultCheck = @"Transaction failed!";
                
            }
            
            // Create an alert controller to display the transaction result
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:resultCheck
                                                                           message:paymentResult
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:
                                            UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                
                                                NSLog(@"You pressed button OK");
                                            }];
            
            [alert addAction:defaultAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        });
    }] resume];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
