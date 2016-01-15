//
//  AOZTableViewProvider.m
//  AOZTableViewProvider
//
//  Created by Aoisorani on 11/26/15.
//  Copyright © 2015 Aozorany. All rights reserved.
//


#import "AOZTableViewProvider.h"
#import "AOZTableViewProviderUtils.h"
#import "AOZTableViewConfigFileParser.h"
#import "AOZTableViewCell.h"


#pragma mark -
id collectionForIndex(id parentCollection, NSInteger index);
id collectionForIndex(id parentCollection, NSInteger index) {
    if ((![parentCollection isKindOfClass:[AOZTVPSectionCollection class]] && ![parentCollection isKindOfClass:[AOZTVPMode class]])
        || index < 0) {//如果parentCollection不是sectionCollection，也不是mode，而且index不合法，则返回空
        return nil;
    }
    
    if ([parentCollection isKindOfClass:[AOZTVPSectionCollection class]]) {
        AOZTVPSectionCollection *sectionCollection = (AOZTVPSectionCollection *) parentCollection;
        if (sectionCollection.rowCollectionsArray.count == 0) {
            return nil;
        }
        for (AOZTVPRowCollection *rowCollection in sectionCollection.rowCollectionsArray) {
            if (NSLocationInRange(index, rowCollection.rowRange)) {
                return rowCollection;
            }
        }
    } else if ([parentCollection isKindOfClass:[AOZTVPMode class]]) {
        AOZTVPMode *mode = (AOZTVPMode *) parentCollection;
        if (mode.sectionCollectionsArray.count == 0) {
            return nil;
        }
        for (AOZTVPSectionCollection *sectionCollection in mode.sectionCollectionsArray) {
            if (NSLocationInRange(index, sectionCollection.sectionRange)) {
                return sectionCollection;
            }//end for index in range check
        }//end for
    }//end for mode and section
    
    //其他情况：找不到，或者又不是mode也不是section，则直接返回空
    return nil;
}


#pragma mark -
@implementation AOZTableViewProvider {
    NSMutableArray<AOZTVPMode *> *_modesArray;
    NSMutableDictionary *_currentConfigDictionary;
}

#pragma mark lifeCircle
- (instancetype)init {
    self = [super init];
    if (self) {
        _modesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark delegate: UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionCount = 0;
    AOZTVPMode *currentMode = [self currentMode];
    AOZTVPSectionCollection *lastSectionCollection = currentMode.sectionCollectionsArray.lastObject;
    sectionCount = lastSectionCollection.sectionRange.location + lastSectionCollection.sectionRange.length;
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = 0;
    AOZTVPMode *currentMode = [self currentMode];
    AOZTVPSectionCollection *sectionCollection = collectionForIndex(currentMode, section);
    if (sectionCollection.rowCollectionsArray.count == 0) {
        rowCount = 1;
    } else {
        AOZTVPRowCollection *lastRowCollection = sectionCollection.rowCollectionsArray.lastObject;
        rowCount = lastRowCollection.rowRange.location + lastRowCollection.rowRange.length;
    }
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AOZTVPMode *currentMode = [self currentMode];
    AOZTVPSectionCollection *sectionCollection = collectionForIndex(currentMode, indexPath.section);
    AOZTVPRowCollection *rowCollection = collectionForIndex(sectionCollection, indexPath.row);
    
    id contents = nil;
    if (![rowCollection.dataConfig.source isEqual:[NSNull null]]) {//如果在row里面设置了数据源，则使用row的设置
        if ([rowCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
            if (rowCollection.dataConfig.elementsPerRow < 0) {//全部数据都在一个单元格的情况
                contents = rowCollection.dataConfig.source;
            } else if (rowCollection.dataConfig.elementsPerRow == 0 || rowCollection.dataConfig.elementsPerRow == 1) {//每个单元格只有一个元素的情况
                contents = ((NSArray *) rowCollection.dataConfig.source)[indexPath.row - rowCollection.rowRange.location];
            } else {//每个单元格有多个元素的情况
                NSRange subRange = NSMakeRange((indexPath.row - rowCollection.rowRange.location) * rowCollection.dataConfig.elementsPerRow, rowCollection.dataConfig.elementsPerRow);
                if (subRange.location + subRange.length >= ((NSArray *) rowCollection.dataConfig.source).count) {
                    subRange.length = ((NSArray *) rowCollection.dataConfig.source).count - subRange.location;
                }
                contents = [((NSArray *) rowCollection.dataConfig.source) subarrayWithRange:subRange];
            }
        } else {
            contents = rowCollection.dataConfig.source;
        }
    } else if (![sectionCollection.dataConfig.source isEqual:[NSNull null]]) {//如果在section里面设置了数据源，则使用section的设置
        if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
            if (sectionCollection.dataConfig.elementsPerRow < 0) {//全部数据都在一个单元格的情况
                contents = sectionCollection.dataConfig.source;
            } else if (sectionCollection.dataConfig.elementsPerRow == 0 || sectionCollection.dataConfig.elementsPerRow == 1) {//每个单元格只有一个元素的情况
                contents = ((NSArray *) sectionCollection.dataConfig.source)[indexPath.section - sectionCollection.sectionRange.location];
            } else {//每个单元格有多个元素的情况
                NSRange subRange = NSMakeRange((indexPath.section - sectionCollection.sectionRange.location) * sectionCollection.dataConfig.elementsPerRow, sectionCollection.dataConfig.elementsPerRow);
                if (subRange.location + subRange.length >= ((NSArray *) sectionCollection.dataConfig.source).count) {
                    subRange.length = ((NSArray *) sectionCollection.dataConfig.source).count - subRange.location;
                }
                contents = [((NSArray *) sectionCollection.dataConfig.source) subarrayWithRange:subRange];
            }
        } else {
            contents = sectionCollection.dataConfig.source;
        }
    }
    
    AOZTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(rowCollection.dataConfig.cellClass)];
    [cell setContents:contents];
    
    if ([_delegate respondsToSelector:@selector(tableViewProvider:cellForRowAtIndexPath:contents:cell:)]) {
        [_delegate tableViewProvider:self cellForRowAtIndexPath:indexPath contents:contents cell:cell];
    }
    
    return cell;
}

#pragma mark delegate: UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AOZTVPMode *currentMode = [self currentMode];
    AOZTVPSectionCollection *sectionCollection = collectionForIndex(currentMode, indexPath.section);
    AOZTVPRowCollection *rowCollection = collectionForIndex(sectionCollection, indexPath.row);
    
    id contents = nil;
    if (![rowCollection.dataConfig.source isEqual:[NSNull null]]) {//如果在row里面设置了数据源，则使用row的设置
        if ([rowCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
            if (rowCollection.dataConfig.elementsPerRow < 0) {//全部数据都在一个单元格的情况
                contents = rowCollection.dataConfig.source;
            } else if (rowCollection.dataConfig.elementsPerRow == 0 || rowCollection.dataConfig.elementsPerRow == 1) {//每个单元格只有一个元素的情况
                contents = ((NSArray *) rowCollection.dataConfig.source)[indexPath.row - rowCollection.rowRange.location];
            } else {//每个单元格有多个元素的情况
                NSRange subRange = NSMakeRange((indexPath.row - rowCollection.rowRange.location) * rowCollection.dataConfig.elementsPerRow, rowCollection.dataConfig.elementsPerRow);
                if (subRange.location + subRange.length >= ((NSArray *) rowCollection.dataConfig.source).count) {
                    subRange.length = ((NSArray *) rowCollection.dataConfig.source).count - subRange.location;
                }
                contents = [((NSArray *) rowCollection.dataConfig.source) subarrayWithRange:subRange];
            }
        } else {
            contents = rowCollection.dataConfig.source;
        }
    } else if (![sectionCollection.dataConfig.source isEqual:[NSNull null]]) {//如果在section里面设置了数据源，则使用section的设置
        if ([sectionCollection.dataConfig.source isKindOfClass:[NSArray class]]) {
            if (sectionCollection.dataConfig.elementsPerRow < 0) {//全部数据都在一个单元格的情况
                contents = sectionCollection.dataConfig.source;
            } else if (sectionCollection.dataConfig.elementsPerRow == 0 || sectionCollection.dataConfig.elementsPerRow == 1) {//每个单元格只有一个元素的情况
                contents = ((NSArray *) sectionCollection.dataConfig.source)[indexPath.section - sectionCollection.sectionRange.location];
            } else {//每个单元格有多个元素的情况
                NSRange subRange = NSMakeRange((indexPath.section - sectionCollection.sectionRange.location) * sectionCollection.dataConfig.elementsPerRow, sectionCollection.dataConfig.elementsPerRow);
                if (subRange.location + subRange.length >= ((NSArray *) sectionCollection.dataConfig.source).count) {
                    subRange.length = ((NSArray *) sectionCollection.dataConfig.source).count - subRange.location;
                }
                contents = [((NSArray *) sectionCollection.dataConfig.source) subarrayWithRange:subRange];
            }
        } else {
            contents = sectionCollection.dataConfig.source;
        }
    }
    
    return [AOZTableViewCell heightForCell:contents];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[AOZTableViewCell class]]) {
        [((AOZTableViewCell *) cell) willDisplayCell];
    }
    if ([_delegate respondsToSelector:@selector(tableViewProvider:willDisplayCell:forRowAtIndexPath:)]) {
        [_delegate tableViewProvider:self willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tableViewProvider:didEndDisplayingCell:forRowAtIndexPath:)]) {
        [_delegate tableViewProvider:self didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_delegate respondsToSelector:@selector(tableViewProvider:didSelectRowAtIndexPath:)]) {
        [_delegate tableViewProvider:self didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark private: general
- (AOZTVPMode *)currentMode {
    if (_mode < 0 || _mode >= _modesArray.count) {
        return nil;
    }
    return _modesArray[_mode];
}

#pragma mark public: general
- (BOOL)parseConfigFile:(NSError **)pError {
    if (_configBundleFileName.length == 0) {
        return NO;
    }
    
    //检查配置文件存在性
    NSString *configFileName = [_configBundleFileName stringByDeletingPathExtension];
    NSString *configFileExtention = [_configBundleFileName pathExtension];
    if (configFileExtention.length == 0) {
        configFileExtention = @"tableViewConfig";
    }
    NSString *configFilePath = [[NSBundle mainBundle] pathForResource:configFileName ofType:configFileExtention];
    if (![[NSFileManager defaultManager] fileExistsAtPath:configFilePath]) {
        if (pError) {
            *pError = [NSError errorWithDomain:AOZTableViewProviderErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey: @"配置文件不存在"}];
        }
        return NO;
    }
    
    //解析配置文件
    AOZTableViewConfigFileParser *parser = [[AOZTableViewConfigFileParser alloc] initWithFilePath:configFilePath];
    parser.dataProvider = _dataProvider;
    parser.tableView = _tableView;
    NSArray *newModesArray = [parser parseFile:pError];
    
    if (*pError) {
        return NO;
    }
    
    [_modesArray removeAllObjects];
    [_modesArray addObjectsFromArray:newModesArray];
    
    [_tableView registerClass:[AOZTableViewCell class] forCellReuseIdentifier:NSStringFromClass([AOZTableViewCell class])];
    
    return YES;
}

- (void)connectToTableView:(UITableView *)tableView {
    _tableView = tableView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (void)reloadTableView {
    [_tableView reloadData];
}

- (void)reloadData {
    AOZTVPMode *currentMode = [self currentMode];
    [currentMode reloadSections];
}

- (void)reloadDataAndTableView {
    [self reloadData];
    [self reloadTableView];
}

@end
