//
//  SAMCCountryCodeViewController.m
//  SAMCCountryCode
//
//  Created by HJ on 7/21/16.
//  Copyright © 2016 gknows. All rights reserved.
//

#import "SAMCCountryCodeViewController.h"

@interface SAMCCountryCodeViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *countryCodeTableView;
@property (nonatomic, strong) UISearchDisplayController *searchResultController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSDictionary *countryCodeDictionary;
@property (nonatomic, strong) NSArray *indexArray;
@property (nonatomic, strong) NSArray *searchResultArray;

@end

@implementation SAMCCountryCodeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupSubviews];
    [self prepareData];
}

- (void)setupSubviews
{
    self.countryCodeTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.countryCodeTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.countryCodeTableView.dataSource = self;
    self.countryCodeTableView.delegate = self;
    self.countryCodeTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.countryCodeTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.countryCodeTableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.countryCodeTableView.tableHeaderView = self.searchBar;
    
    self.searchResultController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
                                                                    contentsController:self];
    self.searchResultController.delegate = self;
    self.searchResultController.searchResultsDataSource = self;
    self.searchResultController.searchResultsDelegate = self;
}

- (void)prepareData
{
    NSString *countryCodeListPath = [[NSBundle mainBundle] pathForResource:[self countryCodeFileName]
                                                                    ofType:@"plist"];
    self.countryCodeDictionary = [NSDictionary dictionaryWithContentsOfFile:countryCodeListPath];
    self.indexArray = [self.countryCodeDictionary allKeys];
    self.indexArray = [self.indexArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.countryCodeTableView) {
        NSArray *array = [self.countryCodeDictionary objectForKey:self.indexArray[section]];
        return [array count];
    } else {
        return [self.searchResultArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CountryCodeCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSString *value = nil;
    if (tableView == self.countryCodeTableView) {
        NSString *key = self.indexArray[indexPath.section];
        value = [[self.countryCodeDictionary objectForKey:key] objectAtIndex:indexPath.row];
    } else {
        value = [self.searchResultArray objectAtIndex:indexPath.row];
    }
    NSArray *splitValueList = [value componentsSeparatedByString:@","];
    cell.textLabel.text = splitValueList[0];
    cell.detailTextLabel.text = [splitValueList count] > 1 ? splitValueList[1]:@"";
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.countryCodeTableView) {
        return [self.indexArray count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.indexArray[section] isEqualToString:@"#"]) {
        return [self topHitTitle];
    }
    return self.indexArray[section];
}

// Index
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.countryCodeTableView) {
        return self.indexArray;
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.countryCodeTableView) {
        return index;
    } else {
        return 0;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.countryCodeTableView) {
        return 30;
    } else {
        return 0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.selectBlock != nil) {
        self.selectBlock(cell.detailTextLabel.text);
        self.selectBlock = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *value, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSRange range = [value rangeOfString:searchText options:NSCaseInsensitiveSearch];
        return range.location != NSNotFound;
    }];
    
    NSMutableArray *tempResultArray = [[NSMutableArray alloc] init];
    [self.countryCodeDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *obj, BOOL * _Nonnull stop) {
        if ([key isEqualToString:@"#"]) {
            return;
        }
        [tempResultArray addObjectsFromArray:[obj filteredArrayUsingPredicate:predicate]];
    }];
    
    self.searchResultArray = [tempResultArray sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    [self.searchResultController.searchResultsTableView reloadData];
}

#pragma mark - Private
- (BOOL)isCurrentLanguageSimpleChinese
{
    NSString *currentLaunguage = [[NSLocale preferredLanguages] firstObject];
    // @"zh-Hans" @"zh-Hant" @"zh-HK"
    NSRange range = [currentLaunguage rangeOfString:@"zh-Hans" options:NSCaseInsensitiveSearch];
    return range.location != NSNotFound;
}

- (NSString *)countryCodeFileName
{
    return [self isCurrentLanguageSimpleChinese] ? @"CountryCodeListCh" : @"CountryCodeListEn";
}

- (NSString *)topHitTitle
{
    return [self isCurrentLanguageSimpleChinese] ? @"热门地区" : @"Top hit";
}

@end
