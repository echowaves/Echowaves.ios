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


- (void) reloadWavesPicker {
    [EWWave getAllMyWaves:^(NSArray *waves) {
        self.myWaves = [waves mutableCopy];
        [self.wavesPicker reloadAllComponents];
        
        //        NSLog(@"11111111111 currentWaveName: %@", [APP_DELEGATE currentWaveName]);
        
        if( [APP_DELEGATE currentWaveName] == NULL) {
            NSURLCredential *credential = [EWWave getStoredCredential];
            APP_DELEGATE.currentWaveName = [credential user];
            APP_DELEGATE.currentWaveIndex = 0;
            
            //            [self.wavesPicker reloadAllComponents];
            [self.wavesPicker selectRow:0 animated:NO];
        }
        
        NSLog(@"setting wave index: %ld", [APP_DELEGATE currentWaveIndex]);
        self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
        [self.wavesPicker selectRow:[APP_DELEGATE currentWaveIndex] animated:NO];
        
    } failure:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
    }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    APP_DELEGATE.wavingViewController = self;
    self.delegate = self;

//    self.wavesPicker.style = HPStyle_iOS7;
    self.wavesPicker.font = [UIFont fontWithName: @"Trebuchet MS" size: 14.0f];

    
    //initialize waving switch to yes initially
//    if(![USER_DEFAULTS objectForKey:@"lastCheckTime"]) {
//        [USER_DEFAULTS setBool:YES forKey:@"waving"];
//        [USER_DEFAULTS synchronize];
//    }
    
    [[self selectedWave] setTitle:[APP_DELEGATE currentWaveName] forState:UIControlStateNormal];
    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
}

- (void)updatePhotosCount {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormat setLocale: usLocale];
    
    [EWImage checkForNewAssetsToPostToWaveSinceDate:(NSDate*)[USER_DEFAULTS objectForKey:@"lastCheckTime"]
                                            success:^(NSArray *assets) {
                                                [self photosCount].text =  [NSString stringWithFormat: @"%lu", (unsigned long)[assets count]];
                                            } whenError:^(NSError *error) {
                                                [EWWave showErrorAlertWithMessage:error.description
                                                                       FromSender:nil];
                                                NSLog(@"Error updating photos count");
                                            }];
    
    
    NSString *theDateTime = [dateFormat stringFromDate:[USER_DEFAULTS objectForKey:@"lastCheckTime"]];
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


#pragma mark -  HPickerViewDataSource
- (NSInteger)numberOfRowsInPickerView:pickerView
{
    return [self myWaves].count;
}



#pragma mark -  HPickerViewDelegate
- (NSString *)pickerView:(HorizontalPickerView *)pickerView
             titleForRow:(NSInteger)row
{
    NSLog(@"redrawing row: %ld", (long)row);
    return [((NSDictionary*) [self.myWaves objectAtIndex:row]) objectForKey:@"name"];
}



-(void)pickerView:(HorizontalPickerView *)pickerView
     didSelectRow:(NSInteger)row
{
//    NSLog(@",,,,,,,,,,,,,,,,,,, did select row: %@", @(row));
    APP_DELEGATE.currentWaveName = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"];
    APP_DELEGATE.currentWaveIndex = (long)row;
    //    NSLog(@"setting title: %@", APP_DELEGATE.waveName);
    [[self selectedWave] setTitle:[APP_DELEGATE currentWaveName] forState:UIControlStateNormal];
    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
//    [self startRefresh:self.refreshControl];
}

//-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    NSLog(@"rotating screen");
//    [self reloadWavesPicker];
//}

@end
