//
//  WaveViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "EchoWaveViewController.h"
#import "NavigationTabBarViewController.h"
#import "EWImage.h"
#import "DetailedImagePageViewController.h"


@implementation EchoWaveViewController

- (void) reloadWavesPicker {
//    [EWWave getAllMyWaves:^(NSArray *waves) {
//        self.myWaves = [waves mutableCopy];
//        [self.wavesPicker reloadAllComponents];
//        
////        NSLog(@"11111111111 currentWaveName: %@", [APP_DELEGATE currentWaveName]);
//        
//        if( [APP_DELEGATE currentWaveName] == NULL) {
//            NSURLCredential *credential = [EWWave getStoredCredential];
//            APP_DELEGATE.currentWaveName = [credential user];
//            APP_DELEGATE.currentWaveIndex = 0;
//            
////            [self.wavesPicker reloadAllComponents];
//            [self.wavesPicker selectRow:0 inComponent:0 animated:YES];
//        }
//        
//        NSLog(@"setting wave index: %ld", [APP_DELEGATE currentWaveIndex]);
//        self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
//        [self.wavesPicker selectRow:[APP_DELEGATE currentWaveIndex] inComponent:0 animated:NO];
//        
//    } failure:^(NSError *error) {
//        [EWWave showErrorAlertWithMessage:error.description
//                               FromSender:nil];
//    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"$$$$$$$$$$$$$$$$calling viewDidLoad for EchoWaveViewController");

    
    [self emptyWaveLabel].hidden = YES;
    // Add swipeGestures
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(swipeLeftGestureAction:)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(swipeRightGestureAction:)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];
    
    
    
    if(self.refreshControl == nil) {
        self.refreshControl = [UIRefreshControl new];
        [self.refreshControl addTarget:self action:@selector(startRefresh:)
                      forControlEvents:UIControlEventValueChanged];
        [self.imagesCollectionView addSubview:self.refreshControl];
    }
//    [self startRefresh:self.refreshControl];
    
    self.myWaves  = [[NSMutableArray alloc] initWithObjects:@"13-15", @"16-19", @"20-29", @"30-39", @"40-49", @"50-59", @"60-69", @"70-79", @"80-89", @"90-99", @"100-110", @"over 110", nil];

    self.wavesPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self attachPickerToTextField:self.waveSelected :self.wavesPicker];

}


- (IBAction)swipeRightGestureAction:(id)sender {
    NSLog(@"swipeRight called");
    if( APP_DELEGATE.currentWaveIndex > 0) {
        APP_DELEGATE.currentWaveIndex--;
        APP_DELEGATE.currentWaveName = [((NSDictionary*)[self.myWaves objectAtIndex:APP_DELEGATE.currentWaveIndex]) objectForKey:@"name"];
        [self reloadWavesPicker];
//        [self startRefresh:self.refreshControl];
    }
}
- (IBAction)swipeLeftGestureAction:(id)sender {
    NSLog(@"swipeLeft called");
    if( APP_DELEGATE.currentWaveIndex < [self.myWaves count]) {
        APP_DELEGATE.currentWaveIndex++;
        APP_DELEGATE.currentWaveName = [((NSDictionary*)[self.myWaves objectAtIndex:APP_DELEGATE.currentWaveIndex]) objectForKey:@"name"];
        [self reloadWavesPicker];
//        [self startRefresh:self.refreshControl];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadWavesPicker];
    
    self.imagesCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
//    [self startRefresh:self.refreshControl];
}

- (void) startRefresh:(UIRefreshControl *)sender {
    NSLog(@"starting the refresh");
    
    [EWImage getAllImagesForWave:[APP_DELEGATE currentWaveName]
                         success:^(NSArray *waveImages) {
                             self.waveImages = waveImages;
                             NSLog(@"@total images %lu", (unsigned long)[self.waveImages count]);
                             [self.imagesCollectionView reloadData];
                             [self.imagesCollectionView reloadInputViews];
                             if(waveImages.count == 0) {
                                 [self emptyWaveLabel].hidden = NO;
                             } else {
                                 [self emptyWaveLabel].hidden = YES;
                             }
                             [sender endRefreshing];
                         }
                         failure:^(NSError *error) {
                             NSLog(@"error %@", error.description);
                         }];
    
 
}

- (void)attachPickerToTextField: (UITextField*) textField :(UIPickerView*) picker{
    picker.delegate = self;
    picker.dataSource = self;
    
    textField.delegate = self;
    textField.inputView = picker;
}

#pragma mark - Keyboard delegate stuff

// let tapping on the background (off the input field) close the thing
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.waveSelected resignFirstResponder];
//}

#pragma mark - Picker delegate stuff

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.myWaves.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [self.myWaves objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    self.waveSelected.text = [self.myWaves objectAtIndex:row];
    [self.waveSelected resignFirstResponder];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"total images in wave: %lu", (unsigned long)self.waveImages.count);
    return [self.waveImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"@@@at index %d", indexPath.row);
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    UIImageView *waveImageView = (UIImageView *)[cell viewWithTag:100];
    
    NSString* imageName = [((NSDictionary*)[self.waveImages objectAtIndex:indexPath.row]) objectForKey:@"name"];
    NSString* waveName = [((NSDictionary*)[self.waveImages objectAtIndex:indexPath.row]) objectForKey:@"name_2"];
//    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWAWSBucket, waveName, imageName];
    
    
    ((UIImageView *)[cell viewWithTag:100]).image = nil;//[UIImage imageNamed:@"echowave.png"]; // no need to show the background image

    [EWImage loadThumbImage:imageName
                    forWave:waveName
                    success:^(UIImage *image) {
                        if([collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                            ((UIImageView *)[cell viewWithTag:100]).image = image;
                            waveImageView.contentMode = UIViewContentModeScaleAspectFit;
                        }
                    } failure:^(NSError *error) {
                        NSLog(@"error: %@", error.description);
                    }];
    return cell;
}


- (void)collectionView:(UICollectionView *)imagesCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    DetailedImagePageViewController *detailedImagePageViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil] instantiateViewControllerWithIdentifier:@"DetailedImagePageView"];
    
    detailedImagePageViewController.initialViewIndex = indexPath.row;
    detailedImagePageViewController.waveImages = [self waveImages];
    
    [self.navigationController pushViewController:detailedImagePageViewController animated:NO];
    
}




#pragma mark -  UIPickerViewDataSource
- (NSInteger)numberOfRowsInPickerView:pickerView
{
    return [self myWaves].count;
}



#pragma mark -  UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
{
    NSLog(@"redrawing row: %ld", (long)row);
     return [((NSDictionary*) [self.myWaves objectAtIndex:row]) objectForKey:@"name"];
}



-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row
{
    NSLog(@",,,,,,,,,,,,,,,,,,, did select row: %@", @(row));
    APP_DELEGATE.currentWaveName = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"];
    APP_DELEGATE.currentWaveIndex = (long)row;
    //    NSLog(@"setting title: %@", APP_DELEGATE.waveName);
    
    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
    [self startRefresh:self.refreshControl];
}


@end
