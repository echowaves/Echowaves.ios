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
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:500];
    [label setText:[NSString stringWithFormat:@"Row %li in Section %li", (long)[indexPath row], (long)[indexPath section]]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
