//
//  WaveViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "EchoWaveViewController.h"

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
    // Initialize recipe image array
    self.waveImages = [NSArray arrayWithObjects:
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       @"http://echowaves.com/img/dmitry/thumb_201402021422030720.jpg",
                       nil];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"total images in wave: %d", self.waveImages.count);
    return [self.waveImages count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    UIImageView *waveImageView = (UIImageView *)[cell viewWithTag:100];
    
    waveImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.waveImages objectAtIndex:indexPath.row]]]];
    
    return cell;
}

@end
