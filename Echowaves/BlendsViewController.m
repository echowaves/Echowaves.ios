//
//  BlendsViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "Echowaves-Swift.h"
#import "BlendsViewController.h"
#import "NavigationTabBarViewController.h"
#import "AcceptBlendingRequestViewController.h"

@interface UnblendAlertView : UIAlertView
@property (nonatomic) NSString *waveName;
@end
@implementation UnblendAlertView
@end

@implementation BlendsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    self.wavesPicker.style = HPStyle_iOS7;
    //    self.wavesPicker.font = [UIFont fontWithName: @"Trebuchet MS" size: 14.0f];
    
    self.blendedWith = [[NSArray alloc]init];
    [self refreshView];
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
    EWBlend* blend = [EWBlend new];
    [blend getBlendedWith:^(NSArray *waveNames) {
        self.blendedWith = waveNames;
        [self.tableView reloadData];
        [self.tableView reloadInputViews];
    } failure:^(NSError *error) {
        NSLog(@"error %@", error.description);
    }];
}

- (void)attachPickerToTextField: (UITextField*) textField :(UIPickerView*) picker{
    picker.delegate = self;
    picker.dataSource = self;
    
    textField.delegate = self;
    textField.inputView = picker;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"(((((((((((((((((((((viewWillAppear");
    [self reloadWavesPicker];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"---------------numberOfSectionsInTableView");
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSLog(@"---------------titleForHeaderInSection %ld", (long)section);
    
    
    switch(section){
        case 0:
            return [NSString stringWithFormat:@"%@ blends with: %lu",
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
            waveLabel.text = [((NSDictionary*)[self.blendedWith objectAtIndex:indexPath.row]) objectForKey:@"name"];
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.clipsToBounds = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    return height;
}

//- (IBAction)acceptButtonClicked:(id)sender {
//    UIView *button = sender;
//    NSString *waveName;
//
//    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
//        if ([parent isKindOfClass: [UITableViewCell class]]) {
//            UITableViewCell *cell = (UITableViewCell *) parent;
//            NSIndexPath *path = [self.tableView indexPathForCell: cell];
//            waveName = [((NSDictionary*)[self.requestedBlends objectAtIndex:path.row]) objectForKey:@"name"];
//
//            AcceptBlendingRequestViewController *pickAWaveViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"PickAWaveView"];
//
//            pickAWaveViewController.fromWave = waveName;
//            pickAWaveViewController.toWave = [APP_DELEGATE currentWaveName];
//
//            [self.navigationController pushViewController:pickAWaveViewController animated:NO];
//            break; // for
//        }
//    }
////    NSLog(@"accepting blend request from %@",waveName);
//}

//- (IBAction)rejectButtonClicked:(id)sender {
//    UIView *button = sender;
//    NSString *waveName;
//
//    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
//        if ([parent isKindOfClass: [UITableViewCell class]]) {
//            UITableViewCell *cell = (UITableViewCell *) parent;
//            NSIndexPath *path = [self.tableView indexPathForCell: cell];
//            waveName = [((NSDictionary*)[self.requestedBlends objectAtIndex:path.row]) objectForKey:@"name"];
//
//            UnblendAlertView *alertMessage = [[UnblendAlertView alloc] initWithTitle:@"Alert"
//                                                                   message:@"Unblend?"
//                                                                  delegate:self
//                                                         cancelButtonTitle:@"Cancel"
//                                                         otherButtonTitles:@"OK", nil];
//            alertMessage.waveName = waveName;
//            alertMessage.tag = 20001;
//            [alertMessage show];
//
//            break; // for
//        }
//    }
//    NSLog(@"rejecting blend request from %@",waveName);
//}

//- (IBAction)unblendButtonClicked:(id)sender {
//    UIView *button = sender;
//    NSString *waveName;
//
//    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
//        if ([parent isKindOfClass: [UITableViewCell class]]) {
//            UITableViewCell *cell = (UITableViewCell *) parent;
//            NSIndexPath *path = [self.tableView indexPathForCell: cell];
//            waveName = [((NSDictionary*)[self.unconfirmedBlends objectAtIndex:path.row]) objectForKey:@"name"];
//
//            UnblendAlertView *alertMessage = [[UnblendAlertView alloc] initWithTitle:@"Alert"
//                                                                             message:@"Unblend?"
//                                                                            delegate:self
//                                                                   cancelButtonTitle:@"Cancel"
//                                                                   otherButtonTitles:@"OK", nil];
//            alertMessage.waveName = waveName;
//            alertMessage.tag = 20002;
//            [alertMessage show];
//
//
//            break; // for
//        }
//    }
//
//    NSLog(@"unblending wave %@",waveName);
//}

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
            EWBlend* blend = [EWBlend new];
        [blend unblendFrom:[(UnblendAlertView *)alertView waveName]
                 currentWave:[APP_DELEGATE currentWaveName]
                     success:^{
                         [self refreshView];
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
            nil;
            AcceptBlendingRequestViewController *pickAWaveViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"PickAWaveView"];
            pickAWaveViewController.origToWave = [APP_DELEGATE currentWaveName];
            pickAWaveViewController.toWave = [APP_DELEGATE currentWaveName];
            pickAWaveViewController.fromWave = [((NSDictionary*)[self.blendedWith objectAtIndex:indexPath.row]) objectForKey:@"name"];
            
            [self.navigationController pushViewController:pickAWaveViewController animated:NO];
            
            break;
    }
    
    
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
