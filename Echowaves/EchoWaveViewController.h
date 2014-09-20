//
//  WaveViewController.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EchoWaveViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@property (strong, atomic) NSArray *waveImages;

@property (strong, nonatomic) IBOutlet UITextField *waveSelected;
@property (strong, nonatomic) IBOutlet UIPickerView *wavesPicker;
@property (strong, nonatomic) NSMutableArray *myWaves;

@property (weak, nonatomic) IBOutlet UILabel *emptyWaveLabel;



@property (strong, atomic) UIRefreshControl *refreshControl;


@end
