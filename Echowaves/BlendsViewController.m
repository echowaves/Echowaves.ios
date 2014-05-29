//
//  BlendsViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "BlendsViewController.h"
#import "NavigationTabBarViewController.h"
#import "EWBlend.h"
#import "AcceptBlendingRequestViewController.h"

@interface UnblendAlertView : UIAlertView
@property (nonatomic) NSString *waveName;
@end
@implementation UnblendAlertView
@end

@implementation BlendsViewController

- (void) reloadWavesPicker {
    [EWWave getAllMyWaves:^(NSArray *waves) {
        self.myWaves = [waves mutableCopy];
        [self.wavesPicker reloadAllComponents];
        
        NSLog(@"11111111111 currentWaveName: %@", [APP_DELEGATE currentWaveName]);
        
        if( [APP_DELEGATE currentWaveName] == NULL) {
            NSURLCredential *credential = [EWWave getStoredCredential];
            APP_DELEGATE.currentWaveName = [credential user];
            APP_DELEGATE.currentWaveIndex = 0;
            
            //            [self.wavesPicker reloadAllComponents];
            [self.wavesPicker selectRow:0 animated:YES];
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
    
    self.wavesPicker.style = HPStyle_iOS7;
    self.wavesPicker.font = [UIFont fontWithName: @"Trebuchet MS" size: 14.0f];
    
    self.requestedBlends = [[NSArray alloc]init];
    self.unconfirmedBlends = [[NSArray alloc]init];
    self.blendedWith = [[NSArray alloc]init];
    [self reloadView];
}

-(void)reloadView {
    [EWBlend getRequestedBlends:^(NSArray *waveNames) {
        self.requestedBlends = waveNames;
        [self.tableView reloadData];
        [self.tableView reloadInputViews];
    } failure:^(NSError *error) {
        NSLog(@"error %@", error.description);
    }];
    [EWBlend getUnconfirmedBlends:^(NSArray *waveNames) {
        self.unconfirmedBlends = waveNames;
        [self.tableView reloadData];
        [self.tableView reloadInputViews];
    } failure:^(NSError *error) {
        NSLog(@"error %@", error.description);
    }];
    [EWBlend getBlendedWith:^(NSArray *waveNames) {
        self.blendedWith = waveNames;
        [self.tableView reloadData];
        [self.tableView reloadInputViews];
    } failure:^(NSError *error) {
        NSLog(@"error %@", error.description);
    }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"(((((((((((((((((((((viewWillAppear");
    [self reloadWavesPicker];
    [self reloadView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"---------------numberOfSectionsInTableView");
    return 3;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSLog(@"---------------titleForHeaderInSection %ld", (long)section);
    
    
    switch(section){
        case 0:
            return [NSString stringWithFormat:@"To %@: %lu",
                    [APP_DELEGATE currentWaveName],
                    (unsigned long)[self.requestedBlends count]];
            break;
        case 1:
            return [NSString stringWithFormat:@"From %@: %lu",
                    [APP_DELEGATE currentWaveName],
                    (unsigned long)[self.unconfirmedBlends count]];
            break;
        case 2:
            return [NSString stringWithFormat:@"%@ blends in with: %lu",
                    [APP_DELEGATE currentWaveName],
                    (unsigned long)[self.blendedWith count]];
            break;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"---------------numberOfRowsInSection %ld", (long)section);
    
    switch(section){
        case 0:
            NSLog(@"%lu", (unsigned long)[self.requestedBlends count]);
            return [self.requestedBlends count];
            break;
        case 1:
            NSLog(@"%lu", (unsigned long)[self.unconfirmedBlends count]);
            return [self.unconfirmedBlends count];
            break;
        case 2:
            NSLog(@"%lu", (unsigned long)[self.blendedWith count]);
            return [self.blendedWith count];
            break;
    }
    return 0;
}





-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"--------cellForRowAtIndexPath %ld for section %ld", (long)indexPath.row, (long)indexPath.section);
    UITableViewCell *cell;
    NSString *cellIdentifier;
    switch([indexPath section]){
        case 0:
            cellIdentifier = @"RequestedBlend";
            break;
        case 1:
            cellIdentifier = @"UnconfirmedBlend";
            break;
        case 2:
            cellIdentifier = @"BlendedWith";
            break;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UILabel *waveLabel = (UILabel *)[cell viewWithTag:100];
    
    NSLog(@"wave label: %@", waveLabel.text);
    
    switch([indexPath section]){
        case 0:
            waveLabel.text = [((NSDictionary*)[self.requestedBlends objectAtIndex:indexPath.row]) objectForKey:@"name"];
            break;
        case 1:
            waveLabel.text = [((NSDictionary*)[self.unconfirmedBlends objectAtIndex:indexPath.row]) objectForKey:@"name"];
            break;
        case 2:
            waveLabel.text = [((NSDictionary*)[self.blendedWith objectAtIndex:indexPath.row]) objectForKey:@"name"];
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (IBAction)acceptButtonClicked:(id)sender {
    UIView *button = sender;
    NSString *waveName;
    
    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
        if ([parent isKindOfClass: [UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *) parent;
            NSIndexPath *path = [self.tableView indexPathForCell: cell];
            waveName = [((NSDictionary*)[self.requestedBlends objectAtIndex:path.row]) objectForKey:@"name"];

            AcceptBlendingRequestViewController *pickAWaveViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"PickAWaveView"];

            pickAWaveViewController.fromWave = waveName;
            pickAWaveViewController.toWave = [APP_DELEGATE currentWaveName];

            [self.navigationController pushViewController:pickAWaveViewController animated:NO];
            break; // for
        }
    }
//    NSLog(@"accepting blend request from %@",waveName);
}

- (IBAction)rejectButtonClicked:(id)sender {
    UIView *button = sender;
    NSString *waveName;
    
    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
        if ([parent isKindOfClass: [UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *) parent;
            NSIndexPath *path = [self.tableView indexPathForCell: cell];
            waveName = [((NSDictionary*)[self.requestedBlends objectAtIndex:path.row]) objectForKey:@"name"];
            
            UnblendAlertView *alertMessage = [[UnblendAlertView alloc] initWithTitle:@"Alert"
                                                                   message:@"Unblend?"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                         otherButtonTitles:@"OK", nil];
            alertMessage.waveName = waveName;
            alertMessage.tag = 20001;
            [alertMessage show];
            
            break; // for
        }
    }
    NSLog(@"rejecting blend request from %@",waveName);
}

- (IBAction)unblendButtonClicked:(id)sender {
    UIView *button = sender;
    NSString *waveName;
    
    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
        if ([parent isKindOfClass: [UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *) parent;
            NSIndexPath *path = [self.tableView indexPathForCell: cell];
            waveName = [((NSDictionary*)[self.unconfirmedBlends objectAtIndex:path.row]) objectForKey:@"name"];

            UnblendAlertView *alertMessage = [[UnblendAlertView alloc] initWithTitle:@"Alert"
                                                                             message:@"Unblend?"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Cancel"
                                                                   otherButtonTitles:@"OK", nil];
            alertMessage.waveName = waveName;
            alertMessage.tag = 20002;
            [alertMessage show];

            
            break; // for
        }
    }
    
    NSLog(@"unblending wave %@",waveName);
}

- (IBAction)unblendBlendedButtonClicked:(id)sender {
    UIView *button = sender;
    NSString *waveName;
    
    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
        if ([parent isKindOfClass: [UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *) parent;
            NSIndexPath *path = [self.tableView indexPathForCell: cell];
            waveName = [((NSDictionary*)[self.blendedWith objectAtIndex:path.row]) objectForKey:@"name"];

            UnblendAlertView *alertMessage = [[UnblendAlertView alloc] initWithTitle:@"Alert"
                                                                             message:@"Unblend?"
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Cancel"
                                                                   otherButtonTitles:@"OK", nil];
            alertMessage.waveName = waveName;
            alertMessage.tag = 20003;
            [alertMessage show];

            
            break; // for
        }
    }
    NSLog(@"unblending blended wave %@",waveName);
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {//OK button clicked, let's delete the wave
   
    [EWBlend unblendFrom:[(UnblendAlertView *)alertView waveName]
              currentWave:[APP_DELEGATE currentWaveName]
                 success:^{
                     [self reloadView];
                 }
                 failure:^(NSError *error) {
                     NSLog(@"error: %@", error.debugDescription);
                 }];
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"--------didDeselectRowAtIndexPath %ld for section %ld", (long)indexPath.row, (long)indexPath.section);
    
    
    switch([indexPath section]){
        case 0:
            break;
        case 1:
            break;
        case 2:
            nil;
            AcceptBlendingRequestViewController *pickAWaveViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"PickAWaveView"];
            pickAWaveViewController.fromWave = [((NSDictionary*)[self.blendedWith objectAtIndex:indexPath.row]) objectForKey:@"name"];
            pickAWaveViewController.toWave = [APP_DELEGATE currentWaveName];
            
            [self.navigationController pushViewController:pickAWaveViewController animated:NO];

            
            break;
    }

    
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
    NSLog(@",,,,,,,,,,,,,,,,,,, did select row: %@", @(row));
    APP_DELEGATE.currentWaveName = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"];
    APP_DELEGATE.currentWaveIndex = (long)row;
    //    NSLog(@"setting title: %@", APP_DELEGATE.waveName);
    
    self.navigationController.navigationBar.topItem.title = @"";//;[APP_DELEGATE currentWaveName];
    [self reloadView];
}


@end
