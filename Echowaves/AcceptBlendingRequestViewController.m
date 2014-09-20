//
//  PickAWaveViewController.m
//  Echowaves
//
//  Created by Dmitry on 5/20/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "AcceptBlendingRequestViewController.h"
#import "EWBlend.h"

@implementation AcceptBlendingRequestViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateLabels];
    [self reloadWaves];
}

- (void) updateLabels {
    [self fromWaveLabel].text = [self fromWave];
    [self toWaveLabel].text = [self toWave];
    [self blendWaveLabel].text = [NSString stringWithFormat:@"You will be able to see %@'s photos blended with your wave %@. Your %@'s photos will be visible to %@ as well", [self fromWave], [self toWave], [self toWave], [self fromWave]];
    
    NSLog(@"xxxxxxxxx blend wave text %@", [self fromWave]);
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:FALSE];
}

- (IBAction)acceptAction:(id)sender {
    NSLog(@"called pickAWave POP");
    [EWBlend showLoadingIndicator:nil];
    //if toWave is present as well as fromWave -- we have to unblend first
    if(![self.toWave  isEqualToString:self.origToWave]) {
        NSLock *lock = [NSLock new];
        [lock lock];
        [EWBlend unblendFrom:[self fromWave]
                 currentWave:[self origToWave]
                     success:^{
                         [lock unlock];
                         NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~unblended from:%@ to %@", self.fromWave, self.toWave);
                     }
                     failure:^(NSError *error) {
                         [lock unlock];
                         NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~failed unblending from:%@ to %@", self.fromWave, self.toWave);
                     }];

    }
    
    [EWBlend requestBlendingWith:[self fromWave]
                         success:^{
                             [EWBlend confirmBlendingWith:[self fromWave]
                                                  success:^{
                                                      [EWBlend hideLoadingIndicator:nil];
                                                      [self.navigationController popViewControllerAnimated:FALSE];
                                                  }
                                                  failure:^(NSError *error) {
                                                      [EWBlend showAlertWithMessage:@"Confirming Blending failed" FromSender:nil];
                                                      NSLog(@"failed blending confirming %@", error.debugDescription);
                                                      [EWBlend hideLoadingIndicator:nil];
                                                      [self.navigationController popViewControllerAnimated:FALSE];
                                                  }];
                         } failure:^(NSError *error) {
                             [EWBlend showAlertWithMessage:@"Blending failed" FromSender:nil];
                             NSLog(@"failed blending %@", error.debugDescription);
                             [EWBlend hideLoadingIndicator:nil];
                             [self.navigationController popViewControllerAnimated:FALSE];
                         }];

    

    
}


- (void) reloadWaves {
    [EWWave getAllMyWaves:^(NSArray *waves) {
        self.myWaves = [waves mutableCopy];
        
        if( [APP_DELEGATE currentWaveName] == NULL) {
            NSURLCredential *credential = [EWWave getStoredCredential];
            APP_DELEGATE.currentWaveName = [credential user];
            APP_DELEGATE.currentWaveIndex = 0;
        }
        self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
        
        [self reloadWavesPicker];
        [self.wavesPicker selectRow:[APP_DELEGATE currentWaveIndex] inComponent:0 animated:NO];
    } failure:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
    }];
    
}

- (void) reloadWavesPicker {
    [self.wavesPicker reloadAllComponents];
}



- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    //    NSLog(@"^^^^^^^^^^^^number of child waves: %lu", (unsigned long)[self myWaves].count);
    return [self myWaves].count;
}

-(UIView *)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view {
    //    NSLog(@"redrawing row: %ld", (long)row);
    UIView *subView=[[UIView alloc] init];
    subView.backgroundColor=[UIColor orangeColor];
    
    UILabel *name = [[UILabel alloc] init];
    [name setTextColor:[UIColor darkTextColor]];
    [name setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    [name setText:[((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"]];
    name.textAlignment = NSTextAlignmentRight;
    name.Frame = CGRectMake(10, 0, 230, 30);
    
    [subView addSubview:name];
    
    return subView;
}


-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    NSLog(@",,,,,,,,,,,,,,,,,,, did select row: %ld", (long)row);
    APP_DELEGATE.currentWaveName = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"];
    APP_DELEGATE.currentWaveIndex = (long)row;
    //    NSLog(@"setting title: %@", APP_DELEGATE.waveName);
    
    //    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
    self.toWave = APP_DELEGATE.currentWaveName;
    [self updateLabels];
    //    [self reloadWavesPicker];
}

@end
