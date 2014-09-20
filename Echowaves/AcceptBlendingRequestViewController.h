//
//  PickAWaveViewController.h
//  Echowaves
//
//  Created by Dmitry on 5/20/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcceptBlendingRequestViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel *blendWaveLabel;
@property (strong, nonatomic) IBOutlet UILabel *fromWaveLabel;
@property (strong, nonatomic) IBOutlet UILabel *toWaveLabel;

@property (strong, nonatomic) NSString *fromWave;
@property (strong, nonatomic) NSString *toWave;

@property (strong, nonatomic) IBOutlet UIPickerView *wavesPicker;

@property (strong, nonatomic) NSMutableArray *myWaves;

@property (strong, nonatomic) NSString *origToWave;

@end
