//
//  infosViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 06/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "infosViewController.h"

@interface infosViewController ()

@end

@implementation infosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (IBAction)buttonPressed:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://maps.apple.com/?q=IAE+PARIS,21+rue+broca,Paris,France"];
    [[UIApplication sharedApplication] openURL:url];
    
}
- (IBAction)openWebButonPressed:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://www.iae-paris.com"];
    [[UIApplication sharedApplication] openURL:url];
    
}
- (IBAction)phoneCallButtonPressed:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"tel:0153552800"];
    [[UIApplication sharedApplication] openURL:url];
    
}
- (IBAction)composeMailButtonPressed:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"mailto:iae@univ-paris1.fr"];
    [[UIApplication sharedApplication] openURL:url];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
