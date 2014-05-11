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
#import "DetailedImageViewController.h"


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
            [self.wavesPicker selectRow:0 animated:YES];
        }
        
        NSLog(@"setting wave index: %ld", [APP_DELEGATE currentWaveIndex]);
        self.navigationController.navigationBar.topItem.title = [APP_DELEGATE currentWaveName];
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
    
    self.wavesPicker.style = HPStyle_iOS7;
    self.wavesPicker.font = [UIFont fontWithName: @"Trebuchet MS" size: 14.0f];

    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.imagesCollectionView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadWavesPicker];
    
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
    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWAWSBucket, waveName, imageName];
    
    
    ((UIImageView *)[cell viewWithTag:100]).image = [UIImage imageNamed:@"echowave.png"];

    [EWImage loadImageFromUrl:imageUrl
                      success:^(UIImage *image) {
                          ((UIImageView *)[cell viewWithTag:100]).image = image;
                          waveImageView.contentMode = UIViewContentModeScaleAspectFit;
                      }
                      failure:^(NSError *error) {
                          NSLog(@"error: %@", error.description);
                      }
                     progress:nil];
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"DetailedImageSegue"]) {
        
        UICollectionViewCell *cell = (UICollectionViewCell *)sender;
        NSIndexPath *indexPath = [self.imagesCollectionView indexPathForCell:cell];
        
        NSLog(@"))))))))))))))))))indexPath: %ld", (long)indexPath.row);
        
        DetailedImageViewController *detailedImageViewController = (DetailedImageViewController *)segue.destinationViewController;
        detailedImageViewController.imageFromJson = [self.waveImages objectAtIndex:indexPath.row];
        detailedImageViewController.image = ((UIImageView *)[cell viewWithTag:100]).image;
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
    
    self.navigationController.navigationBar.topItem.title = @"";//[APP_DELEGATE currentWaveName];
    [self startRefresh:self.refreshControl];
}


@end
