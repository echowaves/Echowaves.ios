//
//  EchowavesViewController.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "EchowavesViewController.h"

@interface EchowavesViewController ()

@end

@implementation EchowavesViewController



- (IBAction)startWaving:(UIButton *)sender {
    // perform a basic validation, wave/password non balnk and exist in the server side, and enter a sending loop
    
    
    NSMutableURLRequest *request =
    [[NSMutableURLRequest alloc] initWithURL:
    [NSURL URLWithString:@"http://echowaves.com/verify_credentials"]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"name=%@&pass=%@", _waveName.text, _wavePassword.text];
    
    [request setValue:[NSString
                       stringWithFormat:@"%d", [postString length]]
    
    forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[postString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    // get response
    NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] init];
    NSError *error = [[NSError alloc] init];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"*****************************");
    NSLog(@"Response code: %d", [urlResponse statusCode]);
    NSLog(@"Response ==> %@", result);
    if ([urlResponse statusCode] ==200)
    {
        NSLog(@"user name/password found");
        NSLog(@" wave name %@ ", _waveName.text);
        [_waveName setEnabled:NO];
        [_wavePassword setEnabled:NO];
        [sender setEnabled:NO];
        [sender setTitle:[NSString stringWithFormat:@"Currently waving %@", _waveName.text] forState:UIControlStateNormal];
        
    } else {
        NSLog(@"user name/password not found");
    }


}

@end
