//
//  infosViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 06/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "infosViewController.h"

@interface infosViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
    @property (weak, nonatomic) IBOutlet UIView *myInfosView;
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
    
    // change scrollview height in order to show all content
    [self.myScrollView setContentSize:CGSizeMake(320, 700)];
    
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
- (IBAction)phonCall2buttonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:@"tel:0179361040"]];

}
- (IBAction)map2buttonPressed:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://maps.apple.com/?q=IAE+PARIS,37+rue+de+La+Rochefoucauld,Paris,France"];
    [[UIApplication sharedApplication] openURL:url];

}
- (IBAction)socialButtonPressed:(UIButton*)sender {
    
    NSString *buttonLabel = sender.titleLabel.text;
    NSURL *url;
    
    if ([buttonLabel isEqualToString:@"linkedIn"])
        url = [NSURL URLWithString:@"http://www.linkedin.com/company/iaeparis/products"];
    if ([buttonLabel isEqualToString:@"youtube"])
        url = [NSURL URLWithString:@"http://www.youtube.com/user/iaeparis"];
    if ([buttonLabel isEqualToString:@"facebook"])
        url = [NSURL URLWithString:@"https://www.facebook.com/iaeparis"];
    if ([buttonLabel isEqualToString:@"twitter"])
        url = [NSURL URLWithString:@"https://twitter.com/iaeparis"];
    
    [[UIApplication sharedApplication] openURL:url];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
