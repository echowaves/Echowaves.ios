//
//  PickWavesForUploadViewController.m
//  Echowaves
//
//  Created by Dmitry on 8/12/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "PickWavesForUploadViewController.h"

@interface PickWavesForUploadViewController ()

@end

@implementation PickWavesForUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [EWWave getAllMyWaves:^(NSArray *waves) {
        self.myWaves = waves;
        
        [self.myWavesTableView reloadData];
        [self.myWavesTableView reloadInputViews];
        
    } failure:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
    }];
    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.myWaves count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"wavesPickerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel* label = (UILabel *)[cell.contentView viewWithTag:500];
    UISwitch* waveOn = (UISwitch *)[cell.contentView viewWithTag:501];
    [label setText:[((NSDictionary*)[self.myWaves objectAtIndex:indexPath.row]) objectForKey:@"name"]];
    NSNumber* isActive = [((NSDictionary*)[self.myWaves objectAtIndex:indexPath.row]) objectForKey:@"active"];
    if (isActive.intValue == 1) {
        waveOn.on = YES;
    } else {
        waveOn.on = NO;
    }
    
    return cell;
}

- (IBAction)waveOnClicked:(id)sender {
    UISwitch *waveOn = sender;

    UITableViewCell *cell = (UITableViewCell *)[waveOn superview].superview;
	if(![cell isKindOfClass:[UITableViewCell class]]) { // ios >= 7.0 http://stackoverflow.com/questions/19162725/access-ios-7-hidden-uitableviewcellscrollview
		cell = (UITableViewCell *)cell.superview;
		assert([cell isKindOfClass:[UITableViewCell class]]);
	}
    UILabel* label = (UILabel *)[cell.contentView viewWithTag:500];
    NSString *waveName = label.text;
    
    [EWWave showLoadingIndicator:self];
    [EWWave makeWaveActive:waveName active:waveOn.isOn
                   success:^(NSString *waveName) {
                       [EWWave hideLoadingIndicator:self];
                   } failure:^(NSString *errorMessage) {
                       [EWWave hideLoadingIndicator:self];
                       [EWWave showAlertWithMessage:errorMessage FromSender:self];
                   }];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
