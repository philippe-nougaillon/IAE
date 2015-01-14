//
//  infosViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 06/11/2013.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "infosViewController.h"
#import "ArticlesTableViewController.h"

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
    [self.myScrollView setContentSize:CGSizeMake(320, 700)];

 }

- (void)viewDidAppear:(BOOL)animated
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:@"Infos IAE"
                                                      forKey:kGAIScreenName] build]];
    
}

- (IBAction)buttonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:
     [NSURL URLWithString:@"http://maps.apple.com/?q=IAE+PARIS,21+rue+broca,Paris,France"]];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lien externe"
                                                          action:@"Plan Broca"
                                                           label:nil
                                                           value:nil] build]];
    
}
- (IBAction)openWebButonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.iae-paris.com"]];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lien externe"
                                                          action:@"Site Web de l'IAE"
                                                           label:nil
                                                           value:nil] build]];
    
}
- (IBAction)phoneCallButtonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:0153552800"]];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lien externe"
                                                          action:@"Téléphone Centre Broca"
                                                           label:nil
                                                           value:nil] build]];
    
}
- (IBAction)composeMailButtonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:iae@univ-paris1.fr"]];
    
}
- (IBAction)phonCall2buttonPressed:(id)sender {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:0144081160"]];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lien externe"
                                                          action:@"Téléphone Centre Biopark"
                                                           label:nil
                                                           value:nil] build]];

}
- (IBAction)map2buttonPressed:(id)sender {
    
    NSURL *url = [NSURL URLWithString:@"http://maps.apple.com/?q=IAE+PARIS,8+rue+de+la+Croix+Jarry+75013,Paris,France"];
    [[UIApplication sharedApplication] openURL:url];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lien externe"
                                                          action:@"Plan Centre Biopark"
                                                           label:nil
                                                           value:nil] build]];

}
- (IBAction)socialButtonPressed:(UIButton*)sender {
    
    UIButton *button = (UIButton*)sender;
    NSInteger buttonTag = button.tag;
    NSURL *url;
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    if (buttonTag == 1) {
        url = [NSURL URLWithString:@"https://www.linkedin.com/edu/school?id=153036"];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lien externe"
                                                              action:@"LinkedIn de l'IAE"
                                                               label:nil
                                                               value:nil] build]];
    }
    if (buttonTag == 2) {
        url = [NSURL URLWithString:@"http://www.youtube.com/user/iaeparis"];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lien externe"
                                                              action:@"Chaîne Youtube"
                                                               label:nil
                                                               value:nil] build]];
    }
    if (buttonTag == 3) {
        url = [NSURL URLWithString:@"https://www.facebook.com/iaeparis"];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lien externe"
                                                              action:@"Facebook de l'IAE"
                                                               label:nil
                                                               value:nil] build]];
    }
    if (buttonTag == 4) {
        url = [NSURL URLWithString:@"https://twitter.com/iaeparis"];
        
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Lien externe"
                                                              action:@"Twitter de l'IAE"
                                                               label:nil
                                                               value:nil] build]];
    }
    
    [[UIApplication sharedApplication] openURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
