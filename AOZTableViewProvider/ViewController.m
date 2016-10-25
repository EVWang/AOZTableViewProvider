//
//  ViewController.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import "ViewController.h"
#import "AOZTableViewProvider.h"


NSString *configString = @"\
section -s _dictionary -c TableViewCell\n\
    row -s first -t firstTag\n\
    row -s second -t secondTag\n\
section -s _multipleArray -c TableViewCell -t sectionTag\n\
    row -es subArray";


#pragma mark -
@interface ViewController () <AOZTableViewProviderDelegate>
@end


#pragma mark -
@implementation ViewController {
    AOZTableViewProvider *_tableViewProvider;
    NSArray *_multipleArray;
    NSArray *_array;
    NSArray *_emptyArray;
    NSDictionary *_dictionary;
    NSString *_placeHolder;
}

#pragma mark lifeCircle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _placeHolder = @"";
    _array = @[@"1", @"2", @"3", @"4", @"5"];
//    _emptyArray = @[@[@"1", @"2", @"3", @"4", @"5"], @[@"1", @"2", @"3"]];
    _emptyArray = @[@[@{@"tag": @"id", @"title": @"ID"},
                      @{@"tag": @"name", @"title": @"昵称"}],
                    @[@{@"tag": @"sex", @"title": @"性别"},
                      @{@"tag": @"art", @"title": @"才艺"},
                      @{@"tag": @"city", @"title": @"城市"}],
                    @[@{@"tag": @"time", @"title": @"档期"},
                      @{@"tag": @"price", @"title": @"薪酬"},
                      @{@"tag": @"intro", @"title": @"简介"},
                      @{@"tag": @"award", @"title": @"获奖"}]];
    _multipleArray = @[@{@"subArray": @[@"1"], @"name": @"section name 1"}, @{@"subArray": @[@"3", @"4", @"5"], @"name": @"section name 2"}];
    _dictionary = @{@"first": @"first dictionary value", @"second": @"second dictionary value", @"title": @"This is a dictionary"};
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //mainTableView
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGRect mainTableViewRect = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds));
    UITableView *mainTableView = [[UITableView alloc] initWithFrame:mainTableViewRect style:UITableViewStyleGrouped];
    [self.view addSubview:mainTableView];
    
    //_tableViewProvider
    _tableViewProvider = [[AOZTableViewProvider alloc] initWithFileName:@"ViewController.tableViewConfig" dataProvider:self tableView:mainTableView];
    [_tableViewProvider parseConfigWithError:NULL];
    _tableViewProvider.mode = 0;
    [_tableViewProvider reloadTableView];
    
//    _tableViewProvider = [[AOZTableViewProvider alloc] initWithConfigString:configString dataProvider:self tableView:mainTableView];
//    [_tableViewProvider parseConfigWithError:nil];
//    _tableViewProvider.mode = 0;
//    [_tableViewProvider reloadTableView];
    
    //changeSourceBtn
    UIBarButtonItem *changeSourceBtn = [[UIBarButtonItem alloc] initWithTitle:@"Change Source" style:UIBarButtonItemStyleDone target:self action:@selector(onChangeSourceBtnTouchUpInside)];
    self.navigationItem.rightBarButtonItem = changeSourceBtn;
}

#pragma mark delegate: AOZTableViewProviderDelegate
- (void)tableViewProvider:(AOZTableViewProvider *)provider didSelectRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents {
    [_tableViewProvider.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableViewProvider:(AOZTableViewProvider *)provider canEditRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents {
    NSLog(@"canEditRowAtIndexPath %@", indexPath);
    return YES;
}

- (UITableViewCellEditingStyle)tableViewProvider:(AOZTableViewProvider *)provider editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents {
    NSLog(@"editingStyleForRowAtIndexPath %@", indexPath);
    return UITableViewCellEditingStyleDelete;
}

- (void)tableViewProvider:(AOZTableViewProvider *)provider commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath contents:(id)contents {
    NSLog(@"commitEditingStyle %@", indexPath);
}

#pragma mark private: actions
- (void)onChangeSourceBtnTouchUpInside {
    _placeHolder = @"";
    _array = @[@"5", @"6", @"7", @"8", @"9"];
    _emptyArray = @[@[@{@"tag": @"id", @"title": @"ID"},
                      @{@"tag": @"name", @"title": @"昵称"}],
                    @[@{@"tag": @"sex", @"title": @"性别"},
                      @{@"tag": @"art", @"title": @"才艺"},
                      @{@"tag": @"city", @"title": @"城市"}],
                    @[@{@"tag": @"time", @"title": @"档期"},
                      @{@"tag": @"price", @"title": @"薪酬"},
                      @{@"tag": @"intro", @"title": @"简介"},
                      @{@"tag": @"award", @"title": @"获奖"}]];
    _multipleArray = @[@{@"subArray": @[@"4"], @"name": @"section name 4"}, @{@"subArray": @[@"5", @"6", @"7", @"8", @"9"], @"name": @"section name 5"}];
    _dictionary = @{@"first": @"first dictionary value changed", @"second": @"second dictionary value changed", @"title": @"This is a dictionary changed."};
    
    [_tableViewProvider setNeedsReloadForCurrentMode];
    [_tableViewProvider reloadTableView];
}

@end
