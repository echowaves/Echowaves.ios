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
- (void) reloadWaves {
    [EWWave getAllMyWaves:^(NSArray *waves) {
        self.myWaves = [waves mutableCopy];

        if( [APP_DELEGATE currentWaveName] == NULL) {
            NSURLCredential *credential = [EWWave getStoredCredential];
            APP_DELEGATE.currentWaveName = [credential user];
            APP_DELEGATE.currentWaveIndex = 0;
        }
        self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
        [[self selectedWave] setTitle:[APP_DELEGATE currentWaveName] forState:UIControlStateNormal];

        [self reloadWavesPicker];
        [self reloadWavesPickerSelector];
    
    } failure:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
    }];
    
}

- (void) reloadWavesPicker {
    [self.wavesPicker reloadAllComponents];
    [self.wavesPicker selectRow:[APP_DELEGATE currentWaveIndex] animated:YES];
}

- (void) reloadWavesPickerSelector {
    [self.wavesPickerSelector reloadAllComponents];
    [self.wavesPickerSelector selectRow:[APP_DELEGATE currentWaveIndex] inComponent:0 animated:YES];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    APP_DELEGATE.wavingViewController = self;
    self.delegate = self;

    self.wavesPicker.style = HPStyle_iOS7;
    self.wavesPicker.font = [UIFont fontWithName: @"Trebuchet MS" size: 14.0f];

    
    //initialize waving switch to yes initially
    if(![USER_DEFAULTS objectForKey:@"lastCheckTime"]) {
        [USER_DEFAULTS setBool:YES forKey:@"waving"];
        [USER_DEFAULTS synchronize];
    }
        
    UITapGestureRecognizer* pickerViewGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedPickerView:)];
    pickerViewGR.delegate = self;
    [self.wavesPickerSelector addGestureRecognizer:pickerViewGR];
    [[self selectedWave] setTitle:[APP_DELEGATE currentWaveName] forState:UIControlStateNormal];
    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadWaves];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self checkedAtload] == false) {
        self.checkedAtload = true;
        [APP_DELEGATE checkForInitialViewToPresent]; // only call it once, when the view loads for the first time
    }
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

//- (NSString *)pickerView:(UIPickerView *)pickerView
//             titleForRow:(NSInteger)row
//            forComponent:(NSInteger)component
//{
//    NSLog(@"object for key: %@", [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"active"]);
//    return [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"active"] == 0? @"on":@"off";
//}


-(UIView *)pickerView:(UIPickerView *)pickerView
           viewForRow:(NSInteger)row
         forComponent:(NSInteger)component
          reusingView:(UIView *)view {
//    NSLog(@"redrawing row: %ld", (long)row);
    UIView *subView=[[UIView alloc] init];
    subView.backgroundColor=[UIColor orangeColor];
    
    UISwitch* waveOn = [[UISwitch alloc] init];
    waveOn.tag = 1000;
    waveOn.Frame = CGRectMake(250, 0, 300, 30);
    NSNumber* isActive = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"active"];
    if (isActive.intValue == 1) {
        waveOn.on = YES;
    } else {
        waveOn.on = NO;
    }
    
    UILabel *name = [[UILabel alloc] init];
    [name setTextColor:[UIColor darkTextColor]];
    [name setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    [name setText:[((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"]];
    name.textAlignment = NSTextAlignmentRight;
    name.Frame = CGRectMake(10, 0, 230, 30);

    [subView addSubview:waveOn];
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

    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
    [[self selectedWave] setTitle:[APP_DELEGATE currentWaveName] forState:UIControlStateNormal];
    [self reloadWavesPicker];
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

-(void)tappedPickerView:(id)sender  {
    // A tap has been made, find location and make sure it's on the row, otherwise any tap anywhere will be significant.
    
    UITapGestureRecognizer* gn = (UITapGestureRecognizer*)sender;
    CGPoint tapLocation = [gn locationInView:self.view];
    
    // Get exact frame of row.
    CGRect pickerFrame = self.wavesPickerSelector.frame;
    CGSize rowSize = [self.wavesPickerSelector rowSizeForComponent:0];
    CGRect rowFrame = CGRectMake(0, (pickerFrame.origin.y + ((pickerFrame.size.height - rowSize.height)/2.0)), pickerFrame.size.width, rowSize.height);
    
    if (CGRectContainsPoint(rowFrame, tapLocation)) {// Tap is on selected Row so update data model;
        
        long row = [self.wavesPickerSelector selectedRowInComponent:0];
        NSMutableDictionary* myWave = [[self.myWaves objectAtIndex:row]mutableCopy];
        NSLog(@",,,,,,,,,,,,,,,,,,, did tap on a row: %ld", (long)row);

        BOOL active = [[myWave valueForKeyPath:@"active"] boolValue];

        [EWWave makeWaveActive:[myWave valueForKeyPath:@"name"]
                        active:!active
                       success:^(NSString *waveName) {
                           UISwitch* activeSwitch = (UISwitch *)[[self.wavesPickerSelector viewForRow:row forComponent:0] viewWithTag:1000];
                           [activeSwitch setOn:!active animated:NO];
                           [myWave setValue:[NSNumber numberWithLong:active?0:1] forKey:@"active"];
                           [self.myWaves replaceObjectAtIndex:row withObject:myWave];
                           [self reloadWavesPickerSelector];
                       }
                       failure:^(NSString *errorMessage) {
                           [EWWave showErrorAlertWithMessage:errorMessage FromSender:nil];
                       }];
        
        // From here you should update the values correctly. Below is an example of you could update the UISwitch, but remember you must update the values in the original data source, so that "pickerView:viewForRow:forComponent:reusingView:" updates the rows correctly from then on, else once you scroll the changes will be reveresed, as happens here.
    }
}

//-(void) resetWaves {
//    NSLog(@"##################reseting waves");
//    
//}


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
    [self reloadWavesPickerSelector];
}

@end
