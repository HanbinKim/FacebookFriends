//
//  TimelineViewController.m
//  FacebookFeed
//
//  Created by SDT-1 on 2014. 1. 21..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//

#import "FriendsViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#define FACEBOOK_APPID @"1446711568878033"

@interface FriendsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (strong, nonatomic) ACAccount *facebookAccout;
@property (strong, nonatomic) NSArray *data;

@end

@implementation FriendsViewController

- (void)showFriendlist
{
    ACAccountStore *store = [[ACAccountStore alloc]init];
    ACAccountType *accountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary *options = @{ACFacebookAppIdKey:FACEBOOK_APPID,
                              ACFacebookPermissionsKey:@[@"read_friendlists"],
                              ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    [store requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
        if(error)
        {
            NSLog(@"error:%@",error);
        }
        if(granted)
        {
            NSLog(@"권한승인 성공");
            NSArray *accountList = [store accountsWithAccountType:accountType];
            self.facebookAccout = [accountList lastObject];
            
            [self requsetFriends];
        }
        else
        {
            NSLog(@"권한승인 실패");
        }
    }];
}

- (void)requsetFriends
{
    NSString *urlStr = @"https://graph.facebook.com/me/friends";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSDictionary *params = nil;
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:params];
    request.account = self.facebookAccout;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if(nil!=error)
        {
            NSLog(@"Error : %@",error);
            return;
        }
        __autoreleasing NSError *parseError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
        self.data = result[@"data"];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.table reloadData];
        }];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL"];
    NSDictionary *one = self.data[indexPath.row];
    NSString *contents = one[@"name"];
    cell.textLabel.text = contents;
    return cell;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self showFriendlist];
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
