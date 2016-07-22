//
//  SAMCCountryCodeViewController.h
//  SAMCCountryCode
//
//  Created by HJ on 7/21/16.
//  Copyright © 2016 gknows. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAMCCountryCodeViewController : UIViewController

@property (nonatomic, copy) void(^selectBlock)(NSString *countryCode);

@end
