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

NSMutableArray* imagesCache;

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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"total images in wave: %d", self.waveImages.count);
    return [self.waveImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"@@@at index %d", indexPath.row);
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    UIImageView *waveImageView = (UIImageView *)[cell viewWithTag:100];
    
    
    if(!imagesCache) {
        imagesCache = [NSMutableArray arrayWithCapacity:100];
    }
    if([imagesCache count] < [indexPath row] + 1) {
        NSString* imageName = [((NSDictionary*)[self.waveImages objectAtIndex:indexPath.row]) objectForKey:@"name"];
        NSString* waveName = [((NSDictionary*)[self.waveImages objectAtIndex:indexPath.row]) objectForKey:@"name_2"];
        NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWHost, waveName, imageName];

        [imagesCache insertObject:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]] atIndex:indexPath.row];
    }
    waveImageView.image = [imagesCache objectAtIndex:indexPath.row];
    waveImageView.contentMode = UIViewContentModeScaleAspectFit;

    
    return cell;
}

@end
