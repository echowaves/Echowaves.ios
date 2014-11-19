//
//  WaveDetailsViewController.h
//  Echowaves
//
//  Created by Dmitry on 4/8/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaveDetailsViewController : UIViewController <UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *waveName;
@property (strong, nonatomic) IBOutlet UIButton *deleteWaveButton;
@end
