//
//  BlendsViewController.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BlendsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, atomic) NSArray *blendedWith;

@property (strong, nonatomic) IBOutlet UITextField *waveSelected;
@property (strong, nonatomic) IBOutlet UIPickerView *wavesPicker;
@property (strong, nonatomic) NSArray *myWaves;


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
