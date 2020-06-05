//
//  MMBarricadeResponseSetViewController.m
//
// Copyright (c) 2015 Mutual Mobile (http://www.mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "MMBarricadeResponseSetViewController.h"
#import "MMBarricade.h"
#import "MMBarricadeResponseSelectionViewController.h"


static NSString * const kTableCellIdentifier = @"BasicCellIdentifier";


@interface MMBarricadeResponseSetViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) id<MMBarricadeResponseStore> responseStore;
@property (nonatomic, copy) NSArray *filteredResponseSet;

@end


@implementation MMBarricadeResponseSetViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self instantiateSubviews];
        self.definesPresentationContext = true;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MMBarricade", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStylePlain target:self action:@selector(resetPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
    
    self.responseStore = [MMBarricade responseStore];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
    [self.tableView reloadData];
}


#pragma mark - Actions

- (void)resetPressed:(id)sender {
    [self.responseStore resetResponseSelections];
    [self.tableView reloadData];
}

- (void)donePressed:(id)sender {
    [self.delegate barricadeResponseSetViewControllerTappedDone:self];
}


#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isFiltering) {
        return self.filteredResponseSet.count;
    }
    
    return self.responseStore.allResponseSets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kTableCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    MMBarricadeResponseSet *responseSet;
    if (self.isFiltering) {
        responseSet = self.filteredResponseSet[indexPath.row];
    } else {
        responseSet = self.responseStore.allResponseSets[indexPath.row];
    }
    cell.textLabel.text = responseSet.requestName;
    
    id<MMBarricadeResponse> selectedResponse = [self.responseStore currentResponseForResponseSet:responseSet];
    cell.detailTextLabel.text = selectedResponse.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MMBarricadeResponseSet *responseSet;
    if (self.isFiltering) {
        responseSet = self.filteredResponseSet[indexPath.row];
    } else {
        responseSet = self.responseStore.allResponseSets[indexPath.row];
    }
    
    MMBarricadeResponseSelectionViewController *viewController = [[MMBarricadeResponseSelectionViewController alloc] initWithResponseSet:responseSet];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UISearchController

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterContentForSearchText:searchController.searchBar.text];
}

#pragma mark - Private

- (void)instantiateSubviews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.searchResultsUpdater = self;
    _searchController.obscuresBackgroundDuringPresentation = false;
    _searchController.searchBar.placeholder = @"Search response set";
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = _searchController;
    } else {
        // Fallback on earlier versions
    }
}

- (BOOL)isSearchBarEmpty {
    NSString *searchText = self.searchController.searchBar.text;
    if (searchText) {
        return searchText.length == 0;
    } else {
        return YES;
    }
}

- (void)filterContentForSearchText:(NSString *)searchText {
    NSPredicate *pred =[NSPredicate predicateWithFormat: @"requestName CONTAINS[cd] %@", searchText];
    self.filteredResponseSet = [self.responseStore.allResponseSets filteredArrayUsingPredicate:pred];
    
    [self.tableView reloadData];
}

- (BOOL)isFiltering {
    return self.searchController.isActive && !self.isSearchBarEmpty;
}

@end
