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



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"$$$$$$$$$$$$$$$$calling viewDidLoad for EchoWaveViewController");

    
    [self emptyWaveLabel].hidden = YES;
    
    
    if(self.refreshControl == nil) {
        self.refreshControl = [UIRefreshControl new];
        [self.refreshControl addTarget:self action:@selector(startRefresh:)
                      forControlEvents:UIControlEventValueChanged];
        [self.imagesCollectionView addSubview:self.refreshControl];
    }
    
    [self startRefresh:self.refreshControl];
    
    [self reloadWavesPicker];


    

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
        
//        [self.wavesPicker selectRow:APP_DELEGATE.currentWaveIndex inComponent:0 animated:NO];
        
        NSLog(@"setting wave index: %ld", [APP_DELEGATE currentWaveIndex]);
        self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
        //        [self.wavesPicker selectRow:[APP_DELEGATE currentWaveIndex] inComponent:0 animated:NO];
        
    } failure:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.imagesCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth;
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

#pragma mark - Picker delegate stuff

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSLog(@"5555555555555 numberOfRowsInComponent: %lu", (unsigned long)self.myWaves.count);
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
    NSLog(@"666666666666 titleForRow: %@", waveName);
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
    [self startRefresh:self.refreshControl];
    
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






@end
