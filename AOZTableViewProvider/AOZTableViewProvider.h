//
//  AOZTableViewProvider.h
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import <UIKit/UIKit.h>


/** UITableView的数据源与部分代理提供器, init - configFileUrl - parseConfigFile - connectToTableView - reloadTableView */
@interface AOZTableViewProvider : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSURL *configFileUrl;
@property (nonatomic, readonly) UITableView *tableView;
- (BOOL)parseConfigFile:(NSError **)pError;
- (void)connectToTableView:(UITableView *)tableView;
- (void)reloadTableView;
@end
