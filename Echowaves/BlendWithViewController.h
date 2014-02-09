//
//  BlendWithViewController.h
//  Echowaves
//
//  Created by Dmitry on 2/8/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlendWithViewController : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UISearchBar *blendWithSearchBar;

@property (strong, nonatomic) IBOutlet UITableView *blendsCompletionTable;

@end
