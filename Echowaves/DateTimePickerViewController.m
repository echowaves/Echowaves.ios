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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self dateTimePicker].datePickerMode = UIDatePickerModeDateAndTime;
    
    
    NSDate *dateTime = [USER_DEFAULTS objectForKey:@"lastCheckTime"];
    self.datePicker.date = dateTime;
    self.timePicker.date = dateTime;
}

- (IBAction)setDateTime:(id)sender {
    
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
    
    NSLog(@"%@",date);
    
    
    [USER_DEFAULTS setObject:date forKey:@"lastCheckTime"];
    [USER_DEFAULTS synchronize];

    [self.navigationController popViewControllerAnimated:YES];
}

@end
