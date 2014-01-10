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
    [self.myScrollView setContentSize:CGSizeMake(320, 750)];
    
 }

- (IBAction)buttonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:@"http://maps.apple.com/?q=IAE+PARIS,21+rue+broca,Paris,France"]];
    
}
- (IBAction)openWebButonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.iae-paris.com"]];
    
}
- (IBAction)phoneCallButtonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:0153552800"]];
    
}
- (IBAction)composeMailButtonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:iae@univ-paris1.fr"]];
    
}
- (IBAction)phonCall2buttonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:0179361040"]];

}
- (IBAction)map2buttonPressed:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://maps.apple.com/?q=IAE+PARIS,37+rue+de+La+Rochefoucauld,Paris,France"];
    [[UIApplication sharedApplication] openURL:url];

}
- (IBAction)socialButtonPressed:(UIButton*)sender {
    
    UIButton *button = (UIButton*)sender;
    NSInteger buttonTag = button.tag;
    NSURL *url;
    
    if (buttonTag == 1)
        url = [NSURL URLWithString:@"http://www.linkedin.com/company/iaeparis/products"];
    if (buttonTag == 2)
        url = [NSURL URLWithString:@"http://www.youtube.com/user/iaeparis"];
    if (buttonTag == 3)
        url = [NSURL URLWithString:@"https://www.facebook.com/iaeparis"];
    if (buttonTag == 4)
        url = [NSURL URLWithString:@"https://twitter.com/iaeparis"];
    
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
