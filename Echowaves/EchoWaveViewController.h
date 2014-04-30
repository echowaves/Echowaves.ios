//
//  WaveViewController.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalPickerView.h"

@interface EchoWaveViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, HPickerViewDelegate, HPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@property (strong, atomic) NSArray *waveImages;

@property (strong, nonatomic) IBOutlet HorizontalPickerView *wavesPicker;
@property (strong, nonatomic) NSMutableArray *myWaves;

@property (strong, atomic) UIRefreshControl *refreshControl;


@end
