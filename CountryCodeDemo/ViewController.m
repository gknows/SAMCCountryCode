//
//  ViewController.m
//  CountryCodeDemo
//
//  Created by HJ on 7/21/16.
//  Copyright © 2016 gknows. All rights reserved.
//

#import "ViewController.h"
#import "SAMCCountryCodeViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *countryCodeButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)selectCountryCode:(UIButton *)sender
{
    SAMCCountryCodeViewController *controller = [[SAMCCountryCodeViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    controller.selectBlock = ^(NSString *text) {
//        weakSelf.countryCodeButton.titleLabel.text = text;
        [weakSelf.countryCodeButton setTitle:text forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:controller animated:YES];
}


@end
