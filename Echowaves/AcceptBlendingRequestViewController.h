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
@property (strong, nonatomic) NSString *blendWaveText;

@property (strong, nonatomic) IBOutlet UIPickerView *wavesPicker;

@property (strong, nonatomic) NSMutableArray *myWaves;

@property (strong, nonatomic) NSString *selectedWave;

@end
