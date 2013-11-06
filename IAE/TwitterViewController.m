//
//  SecondViewController.m
//  IAE
//
//  Created by Philippe Nougaillon on 02/10/13.
//  Copyright (c) 2013 Philippe Nougaillon. All rights reserved.
//

#import "TwitterViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "twitterCell.h"

@interface TwitterViewController ()

@property (strong, nonatomic) NSArray *timelineData;
@property (nonatomic) ACAccountStore *accountStore;
@property (weak, nonatomic) IBOutlet UITableView *twitterTableViewList;

@end

@implementation TwitterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // _accountStore = [[ACAccountStore alloc] init];
    //[self fetchTimelineForUser:@"iaeparis"];
    
    [self getTimeline];
    
}

-(void)getTimeline
{

    ACAccount *twitterAccount;
    ACAccountStore *account = [[ACAccountStore alloc] init]; // Creates AccountStore object.
    
    // Asks for the Twitter accounts configured on the device.
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         // If we have access to the Twitter accounts configured on the device we will contact the Twitter API.
         if (granted == YES){
         } else {
             // Handle failure to get account access
             NSLog(@"%@", [error localizedDescription]);
         }
     }];
    
    NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType]; // Retrieves an array of Twitter accounts configured on the device.
    
    // If there is a leat one account we will contact the Twitter API.
    if ([arrayOfAccounts count] > 0) {
        twitterAccount = [arrayOfAccounts lastObject]; // Sets the last account on the device to the twitterAccount variable.
    }

    NSURL *requestAPI = [NSURL URLWithString:@"http://api.twitter.com/1.1/statuses/user_timeline.json"]; // API call that returns entires in a user's timeline.
    
    // The requestAPI requires us to tell it how much data to return so we use a NSDictionary to set the 'count'.
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:@"10" forKey:@"count"];
    [parameters setObject:@"1" forKey:@"include_entities"];
    [parameters setObject:@"iaeparis" forKey:@"screen_name"];

    // This is where we are getting the data using SLRequest.
    
    SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestAPI parameters:parameters];
    
    posts.account = twitterAccount;
    
    // The postRequest: method call now accesses the NSData object returned.
    [posts performRequestWithHandler: ^(NSData *response, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         // The NSJSONSerialization class is then used to parse the data returned and assign it to our array.
         
         self.timelineData = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
         if (self.timelineData.count != 0) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.twitterTableViewList reloadData]; // Here we tell the table view to reload the data it just recieved.
                 
             });
         }
     }];

}

-(void)viewDidAppear:(BOOL)animated
{

    [self.twitterTableViewList reloadData];

}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}


#pragma mark - Tableview Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.timelineData.count;
    
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"twitterCell";
    NSString *imageUrl;
    
    twitterCell *cell = (twitterCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *obj = [self.timelineData objectAtIndex:indexPath.row];
    NSString *text = [obj objectForKey:@"text"];
    //NSString *createdAt = [obj objectForKey:@"created_at"];

    [cell.twitterCellLabel setText:text];
    
    // load user image (async)
    NSDictionary *retweet = [obj objectForKey:@"retweeted_status"];
    if (retweet.count > 0) {
        NSDictionary *user = [retweet objectForKey:@"user"];
        imageUrl = [user objectForKey:@"profile_image_url_https"];
    } else {
        NSDictionary *user = [obj objectForKey:@"user"];
        imageUrl = [user objectForKey:@"profile_image_url"];
    }
    NSURL *imageURL = [NSURL URLWithString:imageUrl];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            cell.twitterProfileImage.image = [UIImage imageWithData:imageData];
        });
    });
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
