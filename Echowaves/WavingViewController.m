//
//  EchowavesViewController.m
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

#import "WavingViewController.h"
#import "EWWave.h"
#import "EWImage.h"
#import "NavigationTabBarViewController.h"

@interface WavingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@end


@implementation WavingViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    APP_DELEGATE.wavingViewController = self;
    self.delegate = self;

//    self.wavesPicker.style = HPStyle_iOS7;
//    self.wavesPicker.font = [UIFont fontWithName: @"Trebuchet MS" size: 14.0f];

    
    //initialize waving switch to yes initially
//    if(![USER_DEFAULTS objectForKey:@"lastCheckTime"]) {
//        [USER_DEFAULTS setBool:YES forKey:@"waving"];
//        [USER_DEFAULTS synchronize];
//    }
    
//    [[self selectedWave] setTitle:[APP_DELEGATE currentWaveName] forState:UIControlStateNormal];
    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
}


- (void) reloadWavesPicker {
    [EWWave getAllMyWaves:^(NSArray *waves) {
        self.myWaves = waves;
        
        NSLog(@"11111111111 currentWaveName: %@", [APP_DELEGATE currentWaveName]);
        
        if( [APP_DELEGATE currentWaveName] == NULL) {
            NSURLCredential *credential = [EWWave getStoredCredential];
            APP_DELEGATE.currentWaveName = [credential user];
            APP_DELEGATE.currentWaveIndex = 0;
        }
        NSLog(@"2222222222 currentWaveName: %@", [APP_DELEGATE currentWaveName]);
        NSLog(@"3333333333 wavesPickerSize: %lu", (unsigned long)self.myWaves.count);
        
        self.wavesPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [self attachPickerToTextField:self.waveSelected :self.wavesPicker];
        
        [self.wavesPicker selectRow:APP_DELEGATE.currentWaveIndex inComponent:0 animated:NO];
        
        NSLog(@"setting wave index: %ld", [APP_DELEGATE currentWaveIndex]);
        self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
        
        [self waveSelected].text = [APP_DELEGATE currentWaveName];
        [self refreshView];
    } failure:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
    }];
}

- (void) refreshView {
//    [[self selectedWave] setTitle:[APP_DELEGATE currentWaveName] forState:UIControlStateNormal];
}


- (void)attachPickerToTextField: (UITextField*) textField :(UIPickerView*) picker{
    picker.delegate = self;
    picker.dataSource = self;
    
    textField.delegate = self;
    textField.inputView = picker;
}


- (void)updatePhotosCount {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormat setLocale: usLocale];

    NSDate* currentDateTime = [USER_DEFAULTS objectForKey:@"lastCheckTime"];

    if(currentDateTime == nil) {
        currentDateTime = [NSDate date];
        [USER_DEFAULTS setObject:currentDateTime forKey:@"lastCheckTime"];
    }
    
    NSString *theDateTime = [dateFormat stringFromDate:currentDateTime];
    
    [EWImage checkForNewAssetsToPostToWaveSinceDate:currentDateTime
                                            success:^(NSArray *assets) {
                                                [self photosCount].text =  [NSString stringWithFormat: @"%lu", (unsigned long)[assets count]];
                                            } whenError:^(NSError *error) {
                                                [EWWave showErrorAlertWithMessage:error.description
                                                                       FromSender:nil];
                                                NSLog(@"Error updating photos count");
                                            }];
    
    
    NSLog(@"Date %@", theDateTime);
    
    //    [[self sinceDateTime] titleLabel].text = theDateTime;
    
    [[self sinceDateTime] setTitle:theDateTime forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!! viewWillApear");
    
    [self updatePhotosCount];


//    [[self sinceDateTime] performSelectorOnMainThread:@selector(setText:) withObject:theDateTime waitUntilDone:NO];

    
    [self reloadWavesPicker];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([self checkedAtload] == false) {
        self.checkedAtload = true;
        [APP_DELEGATE checkForInitialViewToPresent]; // only call it once, when the view loads for the first time
    }
}





-(void) pictureSaved
{
//    [self checkForNewImages];
    [APP_DELEGATE checkForInitialViewToPresent];
}

#pragma mark - Gesture Recogniser Delegate and Action for wavesPicker

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // We need this as it enables multiple gestures to be detected.
    return YES;
}



#pragma mark - Picker delegate stuff

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //    NSLog(@"5555555555555 numberOfRowsInComponent: %lu", (unsigned long)self.myWaves.count);
    return self.myWaves.count;
}

#pragma mark -  UIPickerViewDelegate
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor orangeColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    label.textAlignment = NSTextAlignmentCenter;
    //WithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 60)];
    
    NSString* waveName = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"];
    
    [label setText:waveName];
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    self.waveSelected.text = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"];
    [self.waveSelected resignFirstResponder];
    
    NSLog(@",,,,,,,,,,,,,,,,,,, did select row: %@", @(row));
    APP_DELEGATE.currentWaveName = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"];
    APP_DELEGATE.currentWaveIndex = (long)row;
    //    NSLog(@"setting title: %@", APP_DELEGATE.waveName);
    
    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
    [self refreshView];

}

#pragma mark -  UIPickerViewDataSource
- (NSInteger)numberOfRowsInPickerView:pickerView
{
    return [self myWaves].count;
}


@end
