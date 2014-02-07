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

@interface EchoWaveViewController ()

@end

@implementation EchoWaveViewController

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    // TODO: Select Item
//}
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    // TODO: Deselect item
//}



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"$$$$$$$$$$$$$$$$calling viewDidLoad for EchoWaveViewController");
    self.imagesCollectionView.alwaysBounceVertical = YES;

    
    [self refresh];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(startRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [self.imagesCollectionView addSubview:refreshControl];
}

- (void) refresh {
    
    self.imagesCache = [[NSMutableArray alloc] init];
    
    NavigationTabBarViewController* navigationTabBarViewController = (NavigationTabBarViewController*)self.tabBarController;
    NSString* waveName = navigationTabBarViewController.waveName.title;
    
    [EWImage getAllImagesForWave:waveName
                         success:^(NSArray *waveImages) {
                             self.waveImages = waveImages;
                             NSLog(@"@total images %d", [self.waveImages count]);
                             [self.imagesCollectionView reloadData];
                         }
                         failure:^(NSError *error) {
                             NSLog(@"error %@", error.description);
                         }];

}

- (void) startRefresh:(UIRefreshControl *)sender {
    NSLog(@"starting the refresh");

    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // Instead of sleeping, I do a webrequest here.
        [self refresh];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imagesCollectionView reloadData];
            [sender endRefreshing];
        });
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"total images in wave: %d", self.waveImages.count);
    return [self.waveImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"@@@at index %d", indexPath.row);
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    UIImageView *waveImageView = (UIImageView *)[cell viewWithTag:100];

    NSString* imageName = [((NSDictionary*)[self.waveImages objectAtIndex:indexPath.row]) objectForKey:@"name"];
    NSString* waveName = [((NSDictionary*)[self.waveImages objectAtIndex:indexPath.row]) objectForKey:@"name_2"];
    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWHost, waveName, imageName];


    if( [self.imagesCache count] < indexPath.row +1 ) {
        [self.imagesCache addObject:[UIImage imageNamed:@"echowave.png"]];
        
        [EWImage loadImageFromUrl:imageUrl
                          success:^(UIImage *image) {
                              [self.imagesCache replaceObjectAtIndex:indexPath.row withObject:image];
                              ((UIImageView *)[cell viewWithTag:100]).image = [self.imagesCache objectAtIndex:indexPath.row];
                              
                              waveImageView.contentMode = UIViewContentModeScaleAspectFit;
                          }
                          failure:^(NSError *error) {
                              NSLog(@"error: %@", error.description);
                          }];
    }

    ((UIImageView *)[cell viewWithTag:100]).image = [self.imagesCache objectAtIndex:indexPath.row];
    waveImageView.contentMode = UIViewContentModeScaleAspectFit;

    return cell;
}

@end
