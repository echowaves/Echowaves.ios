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

@interface EchoWaveViewController ()

@end

@implementation EchoWaveViewController
UIRefreshControl *refreshControl;

- (void) reloadWaves {
    [EWWave getAllMyWaves:^(NSArray *waves) {
        //        NSLog(@"zzzzzzzzz loaded %lu waves", (unsigned long)waves.count);
        self.myWaves = [waves mutableCopy];
        [self.wavesPicker reloadAllComponents];
        
        NSLog(@"11111111111 currentWaveName: %@", [APP_DELEGATE currentWaveName]);
        
        if( [APP_DELEGATE currentWaveName] == NULL) {
            NSURLCredential *credential = [EWWave getStoredCredential];
            APP_DELEGATE.currentWaveName = [credential user];
            
            [self.wavesPicker reloadAllComponents];
//            [self.wavesPicker selectRow:0 inComponent:0 animated:YES];
//            [[self selectedWave] setTitle:APP_DELEGATE.currentWaveName forState:UIControlStateNormal];
            self.navigationController.navigationBar.topItem.title = APP_DELEGATE.currentWaveName;
        }
        
    } failure:^(NSError *error) {
        [EWWave showErrorAlertWithMessage:error.description
                               FromSender:nil];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"$$$$$$$$$$$$$$$$calling viewDidLoad for EchoWaveViewController");
    
    [self reloadWaves];
    self.wavesPicker.style = HPStyleNormal;
    self.wavesPicker.font = [UIFont fontWithName: @"Trebuchet MS" size: 14.0f];

    self.imagesCollectionView.alwaysBounceVertical = YES;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.imagesCollectionView addSubview:refreshControl];
    

    //    [self startRefresh:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startRefresh:refreshControl];    
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


- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark -  HPickerViewDataSource
- (NSInteger)numberOfRowsInPickerView:pickerView
{
    //    NSLog(@"^^^^^^^^^^^^number of child waves: %lu", (unsigned long)[self myWaves].count);
    return [self myWaves].count;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView
//             titleForRow:(NSInteger)row
//            forComponent:(NSInteger)component
//{
//    NSLog(@"object for key: %@", [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"active"]);
//    return [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"active"] == 0? @"on":@"off";
//}


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
    NSLog(@",,,,,,,,,,,,,,,,,,, did select row: %ld", (long)row);
    APP_DELEGATE.currentWaveName = [((NSDictionary*)[self.myWaves objectAtIndex:row]) objectForKey:@"name"];
    //    NSLog(@"setting title: %@", APP_DELEGATE.waveName);
    
    self.navigationController.navigationBar.topItem.title = APP_DELEGATE.currentWaveName;
//    [[self selectedWave] setTitle:APP_DELEGATE.currentWaveName forState:UIControlStateNormal];
    [self reloadWaves];
}


@end
