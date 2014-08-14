//
//  PickWavesForUploadViewController.h
//  Echowaves
//
//  Created by Dmitry on 8/12/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickWavesForUploadViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *myWavesTableView;

@property (strong, nonatomic) NSArray *myWaves;

@end
