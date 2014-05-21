//
//  PickAWaveViewController.h
//  Echowaves
//
//  Created by Dmitry on 5/20/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickAWaveViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UILabel *BlendWaveLabel;
@property (strong, nonatomic) IBOutlet UIPickerView *wavesPicker;

@property (strong, nonatomic) NSMutableArray *myWaves;

@end
