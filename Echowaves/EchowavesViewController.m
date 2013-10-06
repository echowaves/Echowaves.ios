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
    
    
    // Setup request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://echowaves.com/login"]];
    [request setHTTPMethod:@"POST"];
    
    // set headers
    NSString *contentType = [NSString stringWithFormat:@"text/plain"];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // setup post string
    NSMutableString *postString = [[NSMutableString alloc] init];
    [postString appendFormat:@"name=%@", _waveName.text];
    [postString appendFormat:@"&pass=%@", _wavePassword.text];
    
    // I've been told not to use setHTTPBody for post variables, but how else do you do it?
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // get response
    NSHTTPURLResponse *urlResponse = nil;
//    NSError *error = [[NSError alloc] init];
    
//    NSData *responseData = [NSURLConnection sendSynchronousRequest:request
//                                                 returningResponse:&urlResponse
//                                                             error:&error];
    
//    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    
    NSLog(@"Response code: %d", [urlResponse statusCode]);
  if ([urlResponse statusCode] >=200 && [urlResponse statusCode] <300)
    {
//        NSLog(@"Response ==> %@", result);
        NSLog(@"user name/password found");
    } else {
        NSLog(@"user name/password not found");
    }

    
    NSLog(@" wave name %@ ", _waveName.text);
    [_waveName setEnabled:NO];
    [_wavePassword setEnabled:NO];
    [sender setEnabled:NO];
    [sender setTitle:@"Currently Waving" forState:UIControlStateNormal];


}

@end
