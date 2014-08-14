//
//  DateTimePickerViewController.m
//  Echowaves
//
//  Created by Dmitry on 8/13/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "DateTimePickerViewController.h"

@interface DateTimePickerViewController ()

@end

@implementation DateTimePickerViewController

- (IBAction)resetToNow:(id)sender {
    NSDate* dateTime = [NSDate new];
    self.datePicker.date = dateTime;
    self.timePicker.date = dateTime;
    
    [EWImage checkForNewAssetsToPostToWaveSinceDate:self.dateFromPickers
                                            success:^(NSArray *assets) {
                                                [self photosCount].text =  [NSString stringWithFormat: @"%lu", (unsigned long)[assets count]];
                                            } whenError:^(NSError *error) {
                                                [EWWave showErrorAlertWithMessage:error.description
                                                                       FromSender:nil];
                                                NSLog(@"Error updating photos count");
                                            }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self dateTimePicker].datePickerMode = UIDatePickerModeDateAndTime;
    
    
    NSDate *dateTime = [USER_DEFAULTS objectForKey:@"lastCheckTime"];
    self.datePicker.date = dateTime;
    self.timePicker.date = dateTime;
    
    [EWImage checkForNewAssetsToPostToWaveSinceDate:self.dateFromPickers
                                            success:^(NSArray *assets) {
                                                [self photosCount].text =  [NSString stringWithFormat: @"%lu", (unsigned long)[assets count]];
                                            } whenError:^(NSError *error) {
                                                [EWWave showErrorAlertWithMessage:error.description
                                                                       FromSender:nil];
                                                NSLog(@"Error updating photos count");
                                            }];

}

- (IBAction)dateChanged:(id)sender {
    NSLog(@"((((((((((((((((((((((( date changed");
    [EWImage checkForNewAssetsToPostToWaveSinceDate:self.dateFromPickers
                                                   success:^(NSArray *assets) {
        [self photosCount].text =  [NSString stringWithFormat: @"%lu", (unsigned long)[assets count]];
    } whenError:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
        NSLog(@"Error updating photos count");
    }];

}
- (IBAction)timeChanged:(id)sender {
    NSLog(@"))))))))))))))))))))))) time changed");
    [EWImage checkForNewAssetsToPostToWaveSinceDate:self.dateFromPickers
                                            success:^(NSArray *assets) {
                                                [self photosCount].text =  [NSString stringWithFormat: @"%lu", (unsigned long)[assets count]];
                                            } whenError:^(NSError *error) {
                                                [EWWave showErrorAlertWithMessage:error.description
                                                                       FromSender:nil];
                                                NSLog(@"Error updating photos count");
                                            }];

}

- (IBAction)setDateTime:(id)sender {
    
    NSDate* date = self.dateFromPickers;
    NSLog(@"%@",date);
    
    
    [USER_DEFAULTS setObject:date forKey:@"lastCheckTime"];
    [USER_DEFAULTS synchronize];

    [self.navigationController popViewControllerAnimated:YES];
}

- (NSDate*) dateFromPickers {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [dateFormatter stringFromDate:self.datePicker.date];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSString *stringFromTime = [timeFormatter stringFromDate:self.timePicker.date];
    
    
    NSString *dateTimeString=[NSString stringWithFormat:@"%@ %@", stringFromDate, stringFromTime];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    NSDate *date = [formatter dateFromString:dateTimeString];
    return date;
}

@end
