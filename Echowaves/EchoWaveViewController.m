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


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"$$$$$$$$$$$$$$$$calling viewDidLoad for EchoWaveViewController");
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
    
    [EWImage getAllImagesForWave:[APP_DELEGATE waveName]
                         success:^(NSArray *waveImages) {
                             self.waveImages = waveImages;
                             NSLog(@"@total images %lu", (unsigned long)[self.waveImages count]);
                             [self.imagesCollectionView reloadData];
                             [self.imagesCollectionView reloadInputViews];
                             [sender endRefreshing];
//                             dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                                 // Instead of sleeping, I do a webrequest here.
//                                 dispatch_async(dispatch_get_main_queue(), ^{
//                                     [self.imagesCollectionView reloadData];
////                                     [self.imagesCollectionView reloadInputViews];
////                                     [sender endRefreshing];
//                                 });
//                             });
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

@end
