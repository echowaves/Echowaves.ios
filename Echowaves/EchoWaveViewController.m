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
    
    self.imagesCache = [NSMutableArray arrayWithCapacity:100];

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

    NSString* imageName = [((NSDictionary*)[self.waveImages objectAtIndex:indexPath.row]) objectForKey:@"name"];
    NSString* waveName = [((NSDictionary*)[self.waveImages objectAtIndex:indexPath.row]) objectForKey:@"name_2"];
    NSString* imageUrl = [NSString stringWithFormat:@"%@/img/%@/thumb_%@", EWHost, waveName, imageName];


//    if([self.imagesCache count] < [indexPath row] + 1) {
//        NSLog(@"................initilizing imageCache");
//        [self.imagesCache insertObject:[UIImage imageNamed:@"echowave.png"] atIndex:indexPath.row];
//        
//        [EWImage loadImageFromUrl:imageUrl
//                          success:^(UIImage *image) {
//                              [self.imagesCache insertObject:image atIndex:indexPath.row];
//                              ((UIImageView *)[cell viewWithTag:100]).image = image;
//                              waveImageView.contentMode = UIViewContentModeScaleAspectFit;
////                              [self.imagesCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
//                              [cell setNeedsDisplay];
//                          }
//                          failure:^(NSError *error) {
//                              NSLog(@"error: %@", error.description);
//                          }];
//        
//    } else {
//        ((UIImageView *)[cell viewWithTag:100]).image = [self.imagesCache objectAtIndex:indexPath.row];
//        waveImageView.contentMode = UIViewContentModeScaleAspectFit;
//    }
    
//    [self.imagesCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];

//    [self.imagesCollectionView reloadInputViews];
//    [self.imagesCollectionView reloadData];
    
    
    
    ((UIImageView *)[cell viewWithTag:100]).image = [UIImage imageNamed:@"echowave.png"];
    waveImageView.contentMode = UIViewContentModeScaleAspectFit;

    [EWImage loadImageFromUrl:imageUrl
                      success:^(UIImage *image) {
                          ((UIImageView *)[cell viewWithTag:100]).image = image;
                          waveImageView.contentMode = UIViewContentModeScaleAspectFit;
                          //                              [self.imagesCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
                          //                              [cell setNeedsDisplay];
                      }
                      failure:^(NSError *error) {
                          NSLog(@"error: %@", error.description);
                      }];

    
//    [cell setNeedsDisplay];
//    cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    return cell;
}

@end
