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
    [EWWave getAllMyWaves:^(NSArray *waves) {
        self.myWaves = [waves mutableCopy];
        [self.wavesPicker reloadAllComponents];
        
//        NSLog(@"11111111111 currentWaveName: %@", [APP_DELEGATE currentWaveName]);
        
        if( [APP_DELEGATE currentWaveName] == NULL) {
            NSURLCredential *credential = [EWWave getStoredCredential];
            APP_DELEGATE.currentWaveName = [credential user];
            APP_DELEGATE.currentWaveIndex = 0;
            
//            [self.wavesPicker reloadAllComponents];
            [self.wavesPicker selectRow:0 animated:NO];
        }
        
        NSLog(@"setting wave index: %ld", [APP_DELEGATE currentWaveIndex]);
        self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
        [self.wavesPicker selectRow:[APP_DELEGATE currentWaveIndex] animated:NO];
        
    } failure:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"$$$$$$$$$$$$$$$$calling viewDidLoad for EchoWaveViewController");

    
    
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
    
    
    
    
    
    self.wavesPicker.style = HPStyle_iOS7;
    self.wavesPicker.font = [UIFont fontWithName: @"Trebuchet MS" size: 14.0f];

    if(self.refreshControl == nil) {
        self.refreshControl = [UIRefreshControl new];
        [self.refreshControl addTarget:self action:@selector(startRefresh:)
                      forControlEvents:UIControlEventValueChanged];
        [self.imagesCollectionView addSubview:self.refreshControl];
    }
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
                             [sender endRefreshing];
                         }
                         failure:^(NSError *error) {
                             NSLog(@"error %@", error.description);
                         }];
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
    
    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
    [self startRefresh:self.refreshControl];
}


@end
