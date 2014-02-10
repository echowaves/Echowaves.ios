//
//  BlendsViewController.m
//  Echowaves
//
//  Created by Dmitry on 1/17/14.
//  Copyright (c) 2014 Echowaves. All rights reserved.
//

#import "BlendsViewController.h"
#import "NavigationTabBarViewController.h"

@interface BlendsViewController ()

@end

@implementation BlendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"------------viewDidLoad");
    self.requestedBlends = @[@"wave1", @"wave2", @"wave3"];
    self.unconfirmedBlends = @[@"wave11", @"wave12", @"wave13"];
    self.blendedWith = @[@"wave21", @"wave22", @"wave23"];
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
            return [NSString stringWithFormat:@"Waves want to blend in with %@: %d",
                    waveName,
                    [self.requestedBlends count]];
            break;
        case 1:
            return [NSString stringWithFormat:@"%@'s requests for blend in: %d",
                    waveName,
                    [self.unconfirmedBlends count]];
            break;
        case 2:
            return [NSString stringWithFormat:@"%@ blends with: %d",
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
    
    switch([indexPath section]){
        case 0:
            cell.textLabel.text = [self.requestedBlends objectAtIndex:[indexPath row]];
            break;
        case 1:
            cell.textLabel.text = [self.unconfirmedBlends objectAtIndex:[indexPath row]];
            break;
        case 2:
            cell.textLabel.text = [self.blendedWith objectAtIndex:[indexPath row]];
            break;
    }
    
    return cell;
}

@end
