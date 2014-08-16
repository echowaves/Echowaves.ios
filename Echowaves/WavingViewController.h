//
//  EchowavesViewController.h
//  Echowaves
//
//  Created by Dmitry on 10/6/13.
//  Copyright (c) 2013 Echowaves. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "HorizontalPickerView.h"
#import "EchowavesImagePickerController.h"


@interface WavingViewController : EchowavesImagePickerController<EchowavesImagePickerControllerProtocol, UIGestureRecognizerDelegate, HPickerViewDelegate, HPickerViewDataSource>

//-(void) resetWaves;
- (void)updatePhotosCount;

//it's a hack, but can't figure out how to make it work with in standard life cycle
@property (strong, nonatomic) IBOutlet HorizontalPickerView *wavesPicker;
@property (nonatomic) bool checkedAtload;


@property (strong, nonatomic) IBOutlet UIButton *selectedWave;
@property (strong, nonatomic) IBOutlet UIButton *sinceDateTime;

@property (strong, nonatomic) IBOutlet UILabel *photosCount;
@property (strong, nonatomic) NSMutableArray *myWaves;

@end
//nsuserdefaults
//http://stackoverflow.com/questions/8565087/afnetworking-and-cookies/17997943#17997943