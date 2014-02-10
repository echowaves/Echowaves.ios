//
//  BlendsViewController.h
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlendsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, atomic) NSArray *requestedBlends;
@property (strong, atomic) NSArray *unconfirmedBlends;
@property (strong, atomic) NSArray *blendedWith;

@end
