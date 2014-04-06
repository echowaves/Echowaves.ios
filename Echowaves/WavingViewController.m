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


- (IBAction)wavingChanged:(id)sender {
    NSLog(@"=======waving changed to: %d", self.waving.on);
    
    if(self.waving.on) {
        NSLog(@"======== reset lastCheckTime");
        [USER_DEFAULTS setObject:[NSDate date] forKey:@"lastCheckTime"];
        [USER_DEFAULTS synchronize];
    } else {

    }
    
    [USER_DEFAULTS setBool:self.waving.on forKey:@"waving"];
    [USER_DEFAULTS synchronize];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    APP_DELEGATE.wavingViewController = self;
    self.delegate = self;
    NSLog(@"=======waving initializing was %d changed to: %d", self.waving.on, [USER_DEFAULTS boolForKey:@"waving"]);
    self.waving.on = [USER_DEFAULTS boolForKey:@"waving"];
    
    [EWWave getAllMyWaves:^(NSArray *waves) {
        NSLog(@"zzzzzzzzz loaded %lu waves", (unsigned long)waves.count);
        self.myWaves = waves;
        [self.wavesPicker reloadAllComponents];
    } failure:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self checkedAtload] == false) {
        self.checkedAtload = true;
        [APP_DELEGATE checkForUpload]; // only call it once, when the view loads for the first time
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
    NSLog(@"^^^^^^^^^^^^number of child waves: %lu", (unsigned long)[self myWaves].count);
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

    UIView *subView=[[UIView alloc] init];
    subView.backgroundColor=[UIColor orangeColor];
    
    UISwitch* waveOn = [[UISwitch alloc] init];
    waveOn.Frame = CGRectMake(250, 0, 300, 30);
    NSNumber* isActive = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"active"];
    NSLog(@"is active %@", isActive);
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
    

//    [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"active"] == 0? @"on":@"off";
    return subView;
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    APP_DELEGATE.waveName = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"];
    NSLog(@"setting title: %@", APP_DELEGATE.waveName);

    self.navigationController.navigationBar.topItem.title = APP_DELEGATE.waveName;
    [self selectedWave].titleLabel.text = APP_DELEGATE.waveName;
}

-(void) pictureSaved
{
//    [self checkForNewImages];
    [APP_DELEGATE checkForUpload];
}



@end
