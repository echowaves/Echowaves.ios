//
//  BlendsViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "BlendsViewController.h"
#import "NavigationTabBarViewController.h"
#import "EWBlend.h"

@interface BlendsViewController ()

@end

@implementation BlendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"------------viewDidLoad");
    self.requestedBlends = [[NSArray alloc]init];
    self.unconfirmedBlends = [[NSArray alloc]init];
    self.blendedWith = [[NSArray alloc]init];
    [self reloadView];
}

-(void)reloadView {
    [EWBlend getRequestedBlends:^(NSArray *waveNames) {
        self.requestedBlends = waveNames;
        [self.tableView reloadData];
        [self.tableView reloadInputViews];
    } failure:^(NSError *error) {
        NSLog(@"error %@", error.description);
    }];
    [EWBlend getUnconfirmedBlends:^(NSArray *waveNames) {
        self.unconfirmedBlends = waveNames;
        [self.tableView reloadData];
        [self.tableView reloadInputViews];
    } failure:^(NSError *error) {
        NSLog(@"error %@", error.description);
    }];
    [EWBlend getBlendedWith:^(NSArray *waveNames) {
        self.blendedWith = waveNames;
        [self.tableView reloadData];
        [self.tableView reloadInputViews];
    } failure:^(NSError *error) {
        NSLog(@"error %@", error.description);
    }];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"(((((((((((((((((((((viewWillAppear");
    [self reloadView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"---------------numberOfSectionsInTableView");
    return 3;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSLog(@"---------------titleForHeaderInSection %d", section);
    
    NavigationTabBarViewController* navigationTabBarViewController = (NavigationTabBarViewController*)self.tabBarController;
    NSString* waveName = navigationTabBarViewController.waveName.title;
    
    
    switch(section){
        case 0:
            return [NSString stringWithFormat:@"To %@: %d",
                    waveName,
                    [self.requestedBlends count]];
            break;
        case 1:
            return [NSString stringWithFormat:@"From %@: %d",
                    waveName,
                    [self.unconfirmedBlends count]];
            break;
        case 2:
            return [NSString stringWithFormat:@"%@ blends in with: %d",
                    waveName,
                    [self.blendedWith count]];
            break;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"---------------numberOfRowsInSection %d", section);
    
    switch(section){
        case 0:
            NSLog(@"%d", [self.requestedBlends count]);
            return [self.requestedBlends count];
            break;
        case 1:
            NSLog(@"%d", [self.unconfirmedBlends count]);
            return [self.unconfirmedBlends count];
            break;
        case 2:
            NSLog(@"%d", [self.blendedWith count]);
            return [self.blendedWith count];
            break;
    }
    return 0;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"--------cellForRowAtIndexPath %d for section %d", indexPath.row, indexPath.section);
    UITableViewCell *cell;
    NSString *cellIdentifier;
    switch([indexPath section]){
        case 0:
            cellIdentifier = @"RequestedBlend";
            break;
        case 1:
            cellIdentifier = @"UnconfirmedBlend";
            break;
        case 2:
            cellIdentifier = @"BlendedWith";
            break;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UILabel *waveLabel = (UILabel *)[cell viewWithTag:100];
    
    NSLog(@"wave label: %@", waveLabel.text);
    
    switch([indexPath section]){
        case 0:
            waveLabel.text = [((NSDictionary*)[self.requestedBlends objectAtIndex:indexPath.row]) objectForKey:@"name"];
            break;
        case 1:
            waveLabel.text = [((NSDictionary*)[self.unconfirmedBlends objectAtIndex:indexPath.row]) objectForKey:@"name"];
            break;
        case 2:
            waveLabel.text = [((NSDictionary*)[self.blendedWith objectAtIndex:indexPath.row]) objectForKey:@"name"];
            break;
    }
    
    return cell;
}

- (IBAction)acceptButtonClicked:(id)sender {
    UIView *button = sender;
    NSString *waveName;
    
    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
        if ([parent isKindOfClass: [UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *) parent;
            NSIndexPath *path = [self.tableView indexPathForCell: cell];
            waveName = [((NSDictionary*)[self.requestedBlends objectAtIndex:path.row]) objectForKey:@"name"];
            [EWBlend confirmBlendingWith:waveName
                                 success:^{
                                     [self reloadView];
                                 }
                                 failure:^(NSError *error) {
                                     NSLog(@"error: %@", error.debugDescription);
                                 }];
            break; // for
        }
    }
    NSLog(@"accepting blend request from %@",waveName);
}

- (IBAction)rejectButtonClicked:(id)sender {
    UIView *button = sender;
    NSString *waveName;
    
    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
        if ([parent isKindOfClass: [UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *) parent;
            NSIndexPath *path = [self.tableView indexPathForCell: cell];
            waveName = [((NSDictionary*)[self.requestedBlends objectAtIndex:path.row]) objectForKey:@"name"];
            [EWBlend unblendFrom:waveName
                         success:^{
                             [self reloadView];
                         }
                         failure:^(NSError *error) {
                             NSLog(@"error: %@", error.debugDescription);
                         }];
            
            break; // for
        }
    }
    NSLog(@"rejecting blend request from %@",waveName);
}

- (IBAction)unblendButtonClicked:(id)sender {
    UIView *button = sender;
    NSString *waveName;
    
    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
        if ([parent isKindOfClass: [UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *) parent;
            NSIndexPath *path = [self.tableView indexPathForCell: cell];
            waveName = [((NSDictionary*)[self.unconfirmedBlends objectAtIndex:path.row]) objectForKey:@"name"];
            [EWBlend unblendFrom:waveName
                         success:^{
                             [self reloadView];
                         }
                         failure:^(NSError *error) {
                             NSLog(@"error: %@", error.debugDescription);
                         }];
            break; // for
        }
    }
    
    NSLog(@"unblending wave %@",waveName);
}

- (IBAction)unblendBlendedButtonClicked:(id)sender {
    UIView *button = sender;
    NSString *waveName;
    
    for (UIView *parent = [button superview]; parent != nil; parent = [parent superview]) {
        if ([parent isKindOfClass: [UITableViewCell class]]) {
            UITableViewCell *cell = (UITableViewCell *) parent;
            NSIndexPath *path = [self.tableView indexPathForCell: cell];
            waveName = [((NSDictionary*)[self.blendedWith objectAtIndex:path.row]) objectForKey:@"name"];
            [EWBlend unblendFrom:waveName
                         success:^{
                             [self reloadView];
                         }
                         failure:^(NSError *error) {
                             NSLog(@"error: %@", error.debugDescription);
                         }];
            break; // for
        }
    }
    NSLog(@"unblending blended wave %@",waveName);
}


@end
