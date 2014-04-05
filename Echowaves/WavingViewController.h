//
//  EchowavesViewController.h
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"

@interface WavingViewController : EchowavesImagePickerController<EchowavesImagePickerControllerProtocol, UIPickerViewDelegate, UIPickerViewDataSource>


//it's a hack, but can't figure out how to make it work with in standard life cycle
@property (nonatomic) bool checkedAtload;

@property (nonatomic) IBOutlet UISwitch *waving;

@property (strong, nonatomic) IBOutlet UIPickerView *wavesPicker;

@property (strong, nonatomic) NSArray *myWaves;

@end
//nsuserdefaults
//http://stackoverflow.com/questions/8565087/afnetworking-and-cookies/17997943#17997943